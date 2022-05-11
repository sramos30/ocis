<?php declare(strict_types=1);
/**
 * ownCloud
 *
 * @author Michael Barz <mbarz@owncloud.com>
 * @copyright Copyright (c) 2021 Michael Barz mbarz@owncloud.com
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License,
 * as published by the Free Software Foundation;
 * either version 3 of the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 */
use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\Gherkin\Node\TableNode;
use Behat\Testwork\Environment\Environment;
use GuzzleHttp\Exception\GuzzleException;
use Psr\Http\Message\ResponseInterface;
use TestHelpers\HttpRequestHelper;
use TestHelpers\SetupHelper;
use PHPUnit\Framework\Assert;

require_once 'bootstrap.php';

/**
 * Context for ocis spaces specific steps
 */
class SpacesContext implements Context {

	/**
	 * @var FeatureContext
	 */
	private FeatureContext $featureContext;

	/**
	 * @var OCSContext
	 */
	private OCSContext $ocsContext;

	/**
	 * @var string
	 */
	private string $baseUrl;

	/**
	 * @var array key is space name and value is the username that created the space
	 */
	private array $createdSpaces;

	/**
	 * @var string
	 */
	private $ocsApiUrl = '/ocs/v2.php/apps/files_sharing/api/v1/shares';

	/**
	 * @param string $spaceName
	 *
	 * @return string name of the user that created the space
	 * @throws Exception
	 */
	public function getSpaceCreator(string $spaceName): string {
		if (!\array_key_exists($spaceName, $this->createdSpaces)) {
			throw new Exception(__METHOD__ . " space '$spaceName' has not been created in this scenario");
		}
		return $this->createdSpaces[$spaceName];
	}

	/**
	 * @param string $spaceName
	 * @param string $spaceCreator
	 *
	 * @return void
	 */
	public function setSpaceCreator(string $spaceName, string $spaceCreator): void {
		$this->createdSpaces[$spaceName] = $spaceCreator;
	}

	/**
	 * @var array
	 */
	private array $availableSpaces;

	/**
	 * @return array
	 */
	public function getAvailableSpaces(): array {
		return $this->availableSpaces;
	}

	/**
	 * @param array $availableSpaces
	 *
	 * @return void
	 */
	public function setAvailableSpaces(array $availableSpaces): void {
		$this->availableSpaces = $availableSpaces;
	}

	/**
	 * response content parsed from XML to an array
	 *
	 * @var array
	 */
	private array $responseXml = [];

	/**
	 * @return array
	 */
	public function getResponseXml(): array {
		return $this->responseXml;
	}

	/**
	 * @param array $responseXml
	 *
	 * @return void
	 */
	public function setResponseXml(array $responseXml): void {
		$this->responseXml = $responseXml;
	}

	/**
	 * space id from last propfind request
	 *
	 * @var string
	 */
	private string $responseSpaceId;

	/**
	 * @param string $responseSpaceId
	 *
	 * @return void
	 */
	public function setResponseSpaceId(string $responseSpaceId): void {
		$this->responseSpaceId = $responseSpaceId;
	}

	/**
	 * @return string
	 */
	public function getResponseSpaceId(): string {
		return $this->responseSpaceId;
	}

	/**
	 * Get SpaceId by Name
	 *
	 * @param $name string
	 *
	 * @return string
	 *
	 * @throws Exception
	 */
	public function getSpaceIdByNameFromResponse(string $name): string {
		$space = $this->getSpaceByNameFromResponse($name);
		Assert::assertIsArray($space, "Space with name $name not found");
		if (!isset($space["id"])) {
			throw new Exception(__METHOD__ . " space with name $name not found");
		}
		return $space["id"];
	}

	/**
	 * Get Space Array by name
	 *
	 * @param string $name
	 *
	 * @return array
	 *
	 * @throws Exception
	 */
	public function getSpaceByNameFromResponse(string $name): array {
		$response = json_decode((string)$this->featureContext->getResponse()->getBody(), true, 512, JSON_THROW_ON_ERROR);
		$spaceAsArray = $response;
		if (isset($response['name']) && $response['name'] === $name) {
			return $response;
		}
		foreach ($spaceAsArray["value"] as $spaceCandidate) {
			if ($spaceCandidate['name'] === $name) {
				return $spaceCandidate;
			}
		}
		return [];
	}

	/**
	 * The method finds available spaces to the user and returns the space by spaceName
	 *
	 * @param string $user
	 * @param string $spaceName
	 *
	 * @return array
	 */
	public function getSpaceByName(string $user, string $spaceName): array {
		$this->theUserListsAllHisAvailableSpacesUsingTheGraphApi($user);

		$spaces = $this->getAvailableSpaces();
		Assert::assertIsArray($spaces[$spaceName], "Space with name $spaceName for user $user not found");
		Assert::assertNotEmpty($spaces[$spaceName]["root"]["webDavUrl"], "WebDavUrl for space with name $spaceName for user $user not found");

		return $spaces[$spaceName];
	}

	/**
	 * The method finds file by fileName and spaceName and returns data of file wich contains in responseHeader
	 * fileName contains the path, if the file is in the folder
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $fileName
	 *
	 * @return array
	 */
	public function getFileData(string $user, string $spaceName, string $fileName): array {
		$space = $this->getSpaceByName($user, $spaceName);
		$fullUrl = $this->baseUrl . "/remote.php/dav/spaces/" . $space["id"] . "/" . $fileName;
		
		$this->featureContext->setResponse(
			HttpRequestHelper::get(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user),
				[],
				"{}"
			)
		);
		$this->featureContext->theHTTPStatusCodeShouldBe(
			200,
			"file $fileName not found"
		);
		return $this->featureContext->getResponse()->getHeaders();
	}

	/**
	 * The method returns fileId
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $fileName
	 *
	 * @return string
	 */
	public function getFileId(string $user, string $spaceName, string $fileName): string {
		$fileData = $this->getFileData($user, $spaceName, $fileName);
		return $fileData["Oc-Fileid"][0];
	}

	/**
	 * The method returns eTag
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $fileName
	 *
	 * @return string
	 */
	public function getETag(string $user, string $spaceName, string $fileName): string {
		$fileData = $this->getFileData($user, $spaceName, $fileName);
		return $fileData["Etag"][0];
	}

	/**
	 * The method returns userId
	 *
	 * @param string $userName
	 *
	 * @return string
	 */
	public function getUserIdByUserName(string $userName): string {
		$fullUrl = $this->baseUrl . "/api/v0/accounts/accounts-list";
		$this->featureContext->setResponse(
			HttpRequestHelper::post(
				$fullUrl,
				"",
				$this->featureContext->getAdminUsername(),
				$this->featureContext->getAdminPassword(),
				[],
				"{}"
			)
		);
		if ($this->featureContext->getResponse()) {
			$rawBody = $this->featureContext->getResponse()->getBody()->getContents();
			$response = \json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR);
			if (isset($response["accounts"])) {
				$accounts = $response["accounts"];
			} else {
				throw new Exception(__METHOD__ . " accounts-list is empty");
			}
		}
		foreach ($accounts as $account) {
			if ($account["preferredName"] === $userName) {
				return $account["id"];
			}
		}
		throw new Exception(__METHOD__ . " user with name $userName not found");
	}

	/**
	 * @BeforeScenario
	 *
	 * @param BeforeScenarioScope $scope
	 *
	 * @return void
	 *
	 * @throws Exception
	 */
	public function setUpScenario(BeforeScenarioScope $scope): void {
		// Get the environment
		$environment = $scope->getEnvironment();
		// Get all the contexts you need in this context
		$this->featureContext = $environment->getContext('FeatureContext');
		$this->ocsContext = $environment->getContext('OCSContext');
		// Run the BeforeScenario function in OCSContext to set it up correctly
		$this->ocsContext->before($scope);
		$this->baseUrl = \trim($this->featureContext->getBaseUrl(), "/");
		SetupHelper::init(
			$this->featureContext->getAdminUsername(),
			$this->featureContext->getAdminPassword(),
			$this->baseUrl,
			$this->featureContext->getOcPath()
		);
	}

	/**
	 * Send Graph List My Spaces Request
	 *
	 * @param  string $user
	 * @param  string $password
	 * @param  string $urlArguments
	 * @param  string $xRequestId
	 * @param  array  $body
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function listMySpacesRequest(
		string $user,
		string $password,
		string $urlArguments = '',
		string $xRequestId = '',
		array  $body = [],
		array  $headers = []
	): ResponseInterface {
		$fullUrl = $this->baseUrl . "/graph/v1.0/me/drives/" . $urlArguments;

		return HttpRequestHelper::get($fullUrl, $xRequestId, $user, $password, $headers, $body);
	}

	/**
	 * Send Graph List Single Space Request
	 *
	 * @param  string $user
	 * @param  string $password
	 * @param  string $urlArguments
	 * @param  string $xRequestId
	 * @param  array  $body
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function listSingleSpaceRequest(
		string $user,
		string $password,
		string $spaceId,
		string $urlArguments = '',
		string $xRequestId = '',
		array  $body = [],
		array  $headers = []
	): ResponseInterface {
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/" . $spaceId . "/" . $urlArguments;

		return HttpRequestHelper::get($fullUrl, $xRequestId, $user, $password, $headers, $body);
	}

	/**
	 * Send Graph Create Space Request
	 *
	 * @param  string $user
	 * @param  string $password
	 * @param  string $body
	 * @param  string $xRequestId
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function sendCreateSpaceRequest(
		string $user,
		string $password,
		string $body,
		string $xRequestId = '',
		array $headers = []
	): ResponseInterface {
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/";

		return HttpRequestHelper::post($fullUrl, $xRequestId, $user, $password, $headers, $body);
	}

	/**
	 * Send Propfind Request to Url
	 *
	 * @param  string $fullUrl
	 * @param  string $user
	 * @param  string $password
	 * @param  string $xRequestId
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function sendPropfindRequestToUrl(
		string $fullUrl,
		string $user,
		string $password,
		string $xRequestId = '',
		array $headers = []
	): ResponseInterface {
		return HttpRequestHelper::sendRequest($fullUrl, $xRequestId, 'PROPFIND', $user, $password, $headers);
	}

	/**
	 * Send Put Request to Url
	 *
	 * @param string $fullUrl
	 * @param string $user
	 * @param string $password
	 * @param string $xRequestId
	 * @param array $headers
	 * @param string $content
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function sendPutRequestToUrl(
		string $fullUrl,
		string $user,
		string $password,
		string $xRequestId = '',
		array $headers = [],
		string $content = ""
	): ResponseInterface {
		return HttpRequestHelper::sendRequest($fullUrl, $xRequestId, 'PUT', $user, $password, $headers, $content);
	}

	/**
	 * @When /^user "([^"]*)" lists all available spaces via the GraphApi$/
	 *
	 * @param string $user
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserListsAllHisAvailableSpacesUsingTheGraphApi(string $user): void {
		$this->featureContext->setResponse(
			$this->listMySpacesRequest(
				$user,
				$this->featureContext->getPasswordForUser($user)
			)
		);
		$this->rememberTheAvailableSpaces();
	}

	/**
	 * @When /^user "([^"]*)" lists all available spaces via the GraphApi with query "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $query
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserListsAllHisAvailableSpacesUsingTheGraphApiWithFilter(string $user, string $query): void {
		$this->featureContext->setResponse(
			$this->listMySpacesRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				"?" . $query
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" looks up the single space "([^"]*)" via the GraphApi by using its id$/
	 *
	 * @param string $user
	 * @param string $query
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserLooksUpTheSingleSpaceUsingTheGraphApiByUsingItsId(string $user, string $spaceName): void {
		$space = $this->getSpaceByName($user, $spaceName);
		Assert::assertIsArray($space);
		Assert::assertNotEmpty($spaceId = $space["id"]);
		Assert::assertNotEmpty($spaceWebDavUrl = $space["root"]["webDavUrl"]);
		$this->featureContext->setResponse(
			$this->listSingleSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$spaceId
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" creates a space "([^"]*)" of type "([^"]*)" with the default quota using the GraphApi$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $spaceType
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theUserCreatesASpaceUsingTheGraphApi(
		string $user,
		string $spaceName,
		string $spaceType
	): void {
		$space = ["Name" => $spaceName, "driveType" => $spaceType];
		$body = json_encode($space, JSON_THROW_ON_ERROR);
		$this->featureContext->setResponse(
			$this->sendCreateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body
			)
		);
		$this->setSpaceCreator($spaceName, $user);
	}

	/**
	 * @When /^user "([^"]*)" creates a space "([^"]*)" of type "([^"]*)" with quota "([^"]*)" using the GraphApi$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $spaceType
	 * @param int    $quota
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theUserCreatesASpaceWithQuotaUsingTheGraphApi(
		string $user,
		string $spaceName,
		string $spaceType,
		int $quota
	): void {
		$space = ["Name" => $spaceName, "driveType" => $spaceType, "quota" => ["total" => $quota]];
		$body = json_encode($space);
		$this->featureContext->setResponse(
			$this->sendCreateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body
			)
		);
		$this->setSpaceCreator($spaceName, $user);
	}

	/**
	 * @When /^the administrator has given "([^"]*)" the role "([^"]*)" using the settings api$/
	 *
	 * @param string $user
	 * @param string $role
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theAdministratorGivesUserTheRole(string $user, string $role): void {
		$admin = $this->featureContext->getAdminUsername();
		$password = $this->featureContext->getAdminPassword();
		$headers = [];
		$bundles = [];
		$accounts = [];
		$assignment = [];

		// get the roles list first
		$fullUrl = $this->baseUrl . "/api/v0/settings/roles-list";
		$this->featureContext->setResponse(HttpRequestHelper::post($fullUrl, "", $admin, $password, $headers, "{}"));
		if ($this->featureContext->getResponse()) {
			$rawBody =  $this->featureContext->getResponse()->getBody()->getContents();
			if (isset(\json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["bundles"])) {
				$bundles = \json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["bundles"];
			}
		}
		$roleToAssign = "";
		foreach ($bundles as $value) {
			// find the selected role
			if ($value["displayName"] === $role) {
				$roleToAssign = $value;
			}
		}
		Assert::assertNotEmpty($roleToAssign, "The selected role $role could not be found");

		// get the accounts list first
		$fullUrl = $this->baseUrl . "/api/v0/accounts/accounts-list";
		$this->featureContext->setResponse(HttpRequestHelper::post($fullUrl, "", $admin, $password, $headers, "{}"));
		if ($this->featureContext->getResponse()) {
			$rawBody = $this->featureContext->getResponse()->getBody()->getContents();
			if (isset(\json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["accounts"])) {
				$accounts = \json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["accounts"];
			}
		}
		$accountToChange = "";
		foreach ($accounts as $account) {
			// find the selected user
			if ($account["preferredName"] === $user) {
				$accountToChange = $account;
			}
		}
		Assert::assertNotEmpty($accountToChange, "The selected account $user does not exist");

		// set the new role
		$fullUrl = $this->baseUrl . "/api/v0/settings/assignments-add";
		$body = json_encode(["account_uuid" => $accountToChange["id"], "role_id" => $roleToAssign["id"]], JSON_THROW_ON_ERROR);

		$this->featureContext->setResponse(HttpRequestHelper::post($fullUrl, "", $admin, $password, $headers, $body));
		if ($this->featureContext->getResponse()) {
			$rawBody = $this->featureContext->getResponse()->getBody()->getContents();
			if (isset(\json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["assignment"])) {
				$assignment = \json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR)["assignment"];
			}
		}

		Assert::assertEquals($accountToChange["id"], $assignment["accountUuid"]);
		Assert::assertEquals($roleToAssign["id"], $assignment["roleId"]);
	}

	/**
	 * Remember the available Spaces
	 *
	 * @return void
	 *
	 * @throws Exception
	 */
	public function rememberTheAvailableSpaces(): void {
		$rawBody =  $this->featureContext->getResponse()->getBody()->getContents();
		$drives = json_decode($rawBody, true, 512, JSON_THROW_ON_ERROR);
		if (isset($drives["value"])) {
			$drives = $drives["value"];
		}

		Assert::assertArrayHasKey(0, $drives, "No drives were found on that endpoint");
		$spaces = [];
		foreach ($drives as $drive) {
			$spaces[$drive["name"]] = $drive;
		}
		$this->setAvailableSpaces($spaces);
		Assert::assertNotEmpty($spaces, "No spaces have been found");
	}

	/**
	 * @When /^user "([^"]*)" lists the content of the space with the name "([^"]*)" using the WebDav Api$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $path
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserListsTheContentOfAPersonalSpaceRootUsingTheWebDAvApi(
		string $user,
		string $spaceName,
		string $foldersPath = ''
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		Assert::assertIsArray($space);
		Assert::assertNotEmpty($spaceId = $space["id"]);
		Assert::assertNotEmpty($spaceWebDavUrl = $space["root"]["webDavUrl"]);
		$this->featureContext->setResponse(
			$this->sendPropfindRequestToUrl(
				$spaceWebDavUrl . '/' . $foldersPath,
				$user,
				$this->featureContext->getPasswordForUser($user),
				"",
				[],
			)
		);
		$this->setResponseSpaceId($spaceId);
		$this->setResponseXml(
			HttpRequestHelper::parseResponseAsXml($this->featureContext->getResponse())
		);
	}

	/**
	 * @Then /^the (?:propfind|search) result of the space should (not|)\s?contain these (?:files|entries):$/
	 *
	 * @param string    $shouldOrNot   (not|)
	 * @param TableNode $expectedFiles
	 *
	 * @return void
	 *
	 * @throws Exception
	 */
	public function thePropfindResultShouldContainEntries(
		string $shouldOrNot,
		TableNode $expectedFiles
	): void {
		$this->propfindResultShouldContainEntries(
			$shouldOrNot,
			$expectedFiles,
		);
	}

	/**
	 * @Then /^the space "([^"]*)" should (not|)\s?contain these (?:files|entries):$/
	 *
	 * @param string    $spaceName
	 * @param string    $shouldOrNot   (not|)
	 * @param TableNode $expectedFiles
	 *
	 * @return void
	 *
	 * @throws Exception|GuzzleException
	 */
	public function theSpaceShouldContainEntries(
		string $spaceName,
		string $shouldOrNot,
		TableNode $expectedFiles
	): void {
		$this->theUserListsTheContentOfAPersonalSpaceRootUsingTheWebDAvApi(
			$this->getSpaceCreator($spaceName),
			$spaceName
		);
		$this->propfindResultShouldContainEntries(
			$shouldOrNot,
			$expectedFiles,
		);
	}

	/**
	 * @Then /^for user "([^"]*)" the space "([^"]*)" should (not|)\s?contain these (?:files|entries):$/
	 *
	 * @param string    $user
	 * @param string    $spaceName
	 * @param string    $shouldOrNot   (not|)
	 * @param TableNode $expectedFiles
	 *
	 * @return void
	 *
	 * @throws Exception|GuzzleException
	 */
	public function userTheSpaceShouldContainEntries(
		string $user,
		string $spaceName,
		string $shouldOrNot,
		TableNode $expectedFiles
	): void {
		$this->theUserListsTheContentOfAPersonalSpaceRootUsingTheWebDAvApi(
			$user,
			$spaceName
		);
		$this->propfindResultShouldContainEntries(
			$shouldOrNot,
			$expectedFiles
		);
	}

	/**
	 * @Then /^for user "([^"]*)" folder "([^"]*)" of the space "([^"]*)" should (not|)\s?contain these (?:files|entries):$/
	 *
	 * @param string    $user
	 * @param string    $folderPath
	 * @param string    $spaceName
	 * @param string    $shouldOrNot   (not|)
	 * @param TableNode $expectedFiles
	 *
	 * @return void
	 *
	 * @throws Exception|GuzzleException
	 */
	public function folderOfTheSpaceShouldContainEntries(
		string $user,
		string $folderPath,
		string $spaceName,
		string $shouldOrNot,
		TableNode $expectedFiles
	): void {
		$this->theUserListsTheContentOfAPersonalSpaceRootUsingTheWebDAvApi(
			$user,
			$spaceName,
			$folderPath
		);
		$this->propfindResultShouldContainEntries(
			$shouldOrNot,
			$expectedFiles,
			$folderPath
		);
	}

	/**
	 * @Then /^the json responded should contain a space "([^"]*)" (?:|(?:owned by|granted to) "([^"]*)" )(?:|(?:with description file|with space image) "([^"]*)" )with these key and value pairs:$/
	 *
	 * @param string $spaceName
	 * @param string $userName
	 * @param TableNode $table
	 *
	 * @return void
	 * @throws Exception
	 */
	public function jsonRespondedShouldContain(
		string $spaceName,
		string $userName = '',
		string $fileName = '',
		TableNode $table
	): void {
		$this->featureContext->verifyTableNodeColumns($table, ['key', 'value']);
		Assert::assertIsArray($spaceAsArray = $this->getSpaceByNameFromResponse($spaceName), "No space with name $spaceName found");
		foreach ($table->getHash() as $row) {
			// remember the original Space Array
			$original = $spaceAsArray;
			$row['value'] = $this->featureContext->substituteInLineCodes(
				$row['value'],
				$this->featureContext->getCurrentUser(),
				[],
				[
					[
						"code" => "%space_id%",
						"function" =>
							[$this, "getSpaceIdByNameFromResponse"],
						"parameter" => [$spaceName]
					],
					[
						"code" => "%user_id%",
						"function" =>
							[$this, "getUserIdByUserName"],
						"parameter" => [$userName]
					],
					[
						"code" => "%file_id%",
						"function" =>
							[$this, "getFileId"],
						"parameter" => [$userName, $spaceName, $fileName]
					],
					[
						"code" => "%eTag%",
						"function" =>
							[$this, "getETag"],
						"parameter" => [$userName, $spaceName, $fileName]
					],
				]
			);
			$segments = explode("@@@", $row["key"]);
			// traverse down in the array
			foreach ($segments as $segment) {
				$arrayKeyExists = \array_key_exists($segment, $spaceAsArray);
				$key = $row["key"];
				Assert::assertTrue($arrayKeyExists, "The key $key does not exist on the response");
				if ($arrayKeyExists) {
					$spaceAsArray = $spaceAsArray[$segment];
				}
			}
			Assert::assertEquals($row["value"], $spaceAsArray);
			// set the spaceArray to the point before traversing
			$spaceAsArray = $original;
		}
	}

	/**
	 * @Then /^the json responded should contain a space "([^"]*)" granted to "([^"]*)" with role "([^"]*)"$/
	 *
	 * @param string $spaceName
	 * @param string $userName
	 * @param string $role
	 *
	 * @return void
	 * @throws Exception
	 */
	public function checkPermissionsInResponse(
		string $spaceName,
		string $userName,
		string $role
	): void {
		Assert::assertIsArray($spaceAsArray = $this->getSpaceByNameFromResponse($spaceName), "No space with name $spaceName found");
		$permissions = $spaceAsArray["root"]["permissions"];
		$userId = $this->getUserIdByUserName($userName);
		
		$userRole = "";
		foreach ($permissions as $permission) {
			foreach ($permission["grantedTo"] as $grantedTo) {
				if ($grantedTo["user"]["id"] === $userId) {
					$userRole = $permission["roles"][0];
				}
			}
		}
		Assert::assertEquals($userRole, $role, "the user $userName with the role $role could not be found");
	}

	/**
	 * @Then /^the json responded should not contain a space with name "([^"]*)"$/
	 *
	 * @param string $spaceName
	 *
	 * @return void
	 * @throws Exception
	 */
	public function jsonRespondedShouldNotContain(
		string $spaceName
	): void {
		Assert::assertEmpty($this->getSpaceByNameFromResponse($spaceName), "space $spaceName should not be available for a user");
	}

	/**
	 * @Then /^the json responded should (not|only|)\s?contain spaces of type "([^"]*)"$/
	 *
	 * @param string $shoulOrNot (not|only|)
	 * @param string $type
	 *
	 * @return void
	 * @throws Exception
	 */
	public function jsonRespondedShouldNotContainSpaceType(
		string $onlyOrNot,
		string $type
	): void {
		Assert::assertNotEmpty(
			$spaces = json_decode(
				(string)$this->featureContext
					->getResponse()->getBody(),
				true,
				512,
				JSON_THROW_ON_ERROR
			)
		);
		$matches = [];
		foreach ($spaces["value"] as $space) {
			if ($onlyOrNot === "not") {
				Assert::assertNotEquals($space["driveType"], $type);
			}
			if ($onlyOrNot === "only") {
				Assert::assertEquals($space["driveType"], $type);
			}
			if ($onlyOrNot === "" && $space["driveType"] === $type) {
				$matches[] = $space;
			}
		}
		if ($onlyOrNot === "") {
			Assert::assertNotEmpty($matches);
		}
	}

	/**
	 * @param string    $shouldOrNot   (not|)
	 * @param TableNode $expectedFiles
	 * @param string $folderPath
	 *
	 * @return void
	 *
	 * @throws Exception
	 */
	public function propfindResultShouldContainEntries(
		string $shouldOrNot,
		TableNode $expectedFiles,
		string $folderPath = ''
	): void {
		$this->verifyTableNodeColumnsCount($expectedFiles, 1);
		$elementRows = $expectedFiles->getRows();
		$should = ($shouldOrNot !== "not");

		foreach ($elementRows as $expectedFile) {
			$fileFound = $this->findEntryFromPropfindResponse(
				$expectedFile[0],
				$folderPath
			);
			if ($should) {
				Assert::assertNotEmpty(
					$fileFound,
					"response does not contain the entry '$expectedFile[0]'"
				);
			} else {
				Assert::assertEmpty(
					$fileFound,
					"response does contain the entry '$expectedFile[0]' but should not"
				);
			}
		}
	}

	/**
	 * Verify that the tableNode contains expected number of columns
	 *
	 * @param TableNode $table
	 * @param int       $count
	 *
	 * @return void
	 *
	 * @throws Exception
	 */
	public function verifyTableNodeColumnsCount(
		TableNode $table,
		int $count
	): void {
		if (\count($table->getRows()) < 1) {
			throw new Exception("Table should have at least one row.");
		}
		$rowCount = \count($table->getRows()[0]);
		if ($count !== $rowCount) {
			throw new Exception("Table expected to have $count rows but found $rowCount");
		}
	}

	/**
	 * parses a PROPFIND response from $this->response into xml
	 * and returns found search results if found else returns false
	 *
	 * @param  string|null $entryNameToSearch
	 *
	 * @return array
	 * string if $entryNameToSearch is given and is found
	 * array if $entryNameToSearch is not given
	 * boolean false if $entryNameToSearch is given and is not found
	 */
	public function findEntryFromPropfindResponse(
		string $entryNameToSearch = null,
		string $folderPath = ''
	): array {
		$spaceId = $this->getResponseSpaceId();
		//if we are using that step the second time in a scenario e.g. 'But ... should not'
		//then don't parse the result again, because the result in a ResponseInterface
		if (empty($this->getResponseXml())) {
			$this->setResponseXml(
				HttpRequestHelper::parseResponseAsXml($this->featureContext->getResponse())
			);
		}
		Assert::assertNotEmpty($this->getResponseXml(), __METHOD__ . ' Response is empty');
		Assert::assertNotEmpty($spaceId, __METHOD__ . ' SpaceId is empty');

		// trim any leading "/" passed by the caller, we can just match the "raw" name
		$trimmedEntryNameToSearch = \trim($entryNameToSearch, "/");

		// topWebDavPath should be something like /remote.php/webdav/ or
		// /remote.php/dav/files/alice/
		$topWebDavPath = "/" . "dav/spaces/" . $spaceId . "/" . $folderPath;

		Assert::assertIsArray(
			$this->responseXml,
			__METHOD__ . " responseXml for space $spaceId is not an array"
		);
		Assert::assertArrayHasKey(
			"value",
			$this->responseXml,
			__METHOD__ . " responseXml for space $spaceId does not have key 'value'"
		);
		$multistatusResults = $this->responseXml["value"];
		$results = [];
		if ($multistatusResults !== null) {
			foreach ($multistatusResults as $multistatusResult) {
				$entryPath = $multistatusResult['value'][0]['value'];
				$entryName = \str_replace($topWebDavPath, "", $entryPath);
				$entryName = \rawurldecode($entryName);
				$entryName = \trim($entryName, "/");
				if ($trimmedEntryNameToSearch === $entryName) {
					return $multistatusResult;
				}
				$results[] = $entryName;
			}
		}
		if ($entryNameToSearch === null) {
			return $results;
		}
		return [];
	}

	/**
	 * @When /^user "([^"]*)" creates a (?:folder|subfolder) "([^"]*)" in space "([^"]*)" using the WebDav Api$/
	 *
	 * @param string $user
	 * @param string $folder
	 * @param string $spaceName
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserCreatesAFolderUsingTheGraphApi(
		string $user,
		string $folder,
		string $spaceName
	): void {
		$exploded = explode('/', $folder);
		$path = '';
		for ($i = 0; $i < \count($exploded); $i++) {
			$path = $path . $exploded[$i] . '/';
			$this->theUserCreatesAFolderToAnotherOwnerSpaceUsingTheGraphApi($user, $path, $spaceName);
		};
	}

	/**
	 * @Given /^user "([^"]*)" has created a (?:folder|subfolder) "([^"]*)" in space "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $folder
	 * @param string $spaceName
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserHasCreateAFolderUsingTheGraphApi(
		string $user,
		string $folder,
		string $spaceName
	): void {
		$this->theUserCreatesAFolderUsingTheGraphApi($user, $folder, $spaceName);

		$this->featureContext->theHTTPStatusCodeShouldBe(
			201,
			"Expected response status code should be 201"
		);
	}

	/**
	 * @When /^user "([^"]*)" creates a folder "([^"]*)" in space "([^"]*)" owned by the user "([^"]*)" using the WebDav Api$/
	 *
	 * @param string $user
	 * @param string $folder
	 * @param string $spaceName
	 * @param string $ownerUser
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 */
	public function theUserCreatesAFolderToAnotherOwnerSpaceUsingTheGraphApi(
		string $user,
		string $folder,
		string $spaceName,
		string $ownerUser = ''
	): void {
		if ($ownerUser === '') {
			$ownerUser = $user;
		}

		$space = $this->getSpaceByName($ownerUser, $spaceName);

		$fullUrl = $this->baseUrl . "/dav/spaces/" . $space['id'] . '/' . $folder;

		$this->featureContext->setResponse(
			$this->sendCreateFolderRequest(
				$fullUrl,
				"MKCOL",
				$user,
				$this->featureContext->getPasswordForUser($user)
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" uploads a file inside space "([^"]*)" with content "([^"]*)" to "([^"]*)" using the WebDAV API$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $content
	 * @param string $destination
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theUserUploadsAFileToSpace(
		string $user,
		string $spaceName,
		string $content,
		string $destination
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		Assert::assertIsArray($space, "Space with name $spaceName not found");
		Assert::assertNotEmpty($space["root"]["webDavUrl"], "WebDavUrl for space with name $spaceName not found");

		$this->featureContext->setResponse(
			$this->sendPutRequestToUrl(
				$space["root"]["webDavUrl"] . "/" . $destination,
				$user,
				$this->featureContext->getPasswordForUser($user),
				"",
				[],
				$content
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" uploads a file inside space "([^"]*)" owned by the user "([^"]*)" with content "([^"]*)" to "([^"]*)" using the WebDAV API$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $ownerUser
	 * @param string $content
	 * @param string $destination
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theUserUploadsAFileToAnotherOwnerSpace(
		string $user,
		string $spaceName,
		string $ownerUser,
		string $content,
		string $destination
	): void {
		$space = $this->getSpaceByName($ownerUser, $spaceName);
		Assert::assertIsArray($space, "Space with name $spaceName not found");
		Assert::assertNotEmpty($space["root"]["webDavUrl"], "WebDavUrl for space with name $spaceName not found");

		$this->featureContext->setResponse(
			$this->sendPutRequestToUrl(
				$space["root"]["webDavUrl"] . "/" . $destination,
				$user,
				$this->featureContext->getPasswordForUser($user),
				"",
				[],
				$content
			)
		);
	}

	/**
	 * Send Graph Create Folder Request
	 *
	 * @param  string $fullUrl
	 * @param  string $method
	 * @param  string $user
	 * @param  string $password
	 * @param  string $xRequestId
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function sendCreateFolderRequest(
		string $fullUrl,
		string $method,
		string $user,
		string $password,
		string $xRequestId = '',
		array $headers = []
	): ResponseInterface {
		return HttpRequestHelper::sendRequest($fullUrl, $xRequestId, $method, $user, $password, $headers);
	}

	/**
	 * @When /^user "([^"]*)" changes the name of the "([^"]*)" space to "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $newName
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function updateSpaceName(
		string $user,
		string $spaceName,
		string $newName
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$spaceId = $space["id"];

		$bodyData = ["Name" => $newName];
		$body = json_encode($bodyData, JSON_THROW_ON_ERROR);

		$this->featureContext->setResponse(
			$this->sendUpdateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body,
				$spaceId
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" changes the description of the "([^"]*)" space to "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $newName
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function updateSpaceDescription(
		string $user,
		string $spaceName,
		string $newDescription
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$spaceId = $space["id"];

		$bodyData = ["description" => $newDescription];
		$body = json_encode($bodyData, JSON_THROW_ON_ERROR);

		$this->featureContext->setResponse(
			$this->sendUpdateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body,
				$spaceId
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" changes the quota of the "([^"]*)" space to "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param int $newQuota
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function updateSpaceQuota(
		string $user,
		string $spaceName,
		int $newQuota
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$spaceId = $space["id"];

		$bodyData = ["quota" => ["total" => $newQuota]];
		$body = json_encode($bodyData, JSON_THROW_ON_ERROR);

		$this->featureContext->setResponse(
			$this->sendUpdateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body,
				$spaceId
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" sets the file "([^"]*)" as a (description|space image)\s? in a special section of the "([^"]*)" space$/
	 *
	 * @param string $user
	 * @param string $file
	 * @param string $type
	 * @param string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function updateSpaceSpecialSection(
		string $user,
		string $file,
		string $type,
		string $spaceName
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$spaceId = $space["id"];
		$fileId = $this->getFileId($user, $spaceName, $file);

		if ($type === "description") {
			$type = "readme";
		} else {
			$type = "image";
		}

		$bodyData = ["special" => [["specialFolder" => ["name" => "$type"], "id" => "$fileId"]]];
		$body = json_encode($bodyData, JSON_THROW_ON_ERROR);

		$this->featureContext->setResponse(
			$this->sendUpdateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body,
				$spaceId
			)
		);
	}

	/**
	 * Send Graph Update Space Request
	 *
	 * @param  string $user
	 * @param  string $password
	 * @param  mixed $body
	 * @param  string $spaceId
	 * @param  string $xRequestId
	 * @param  array  $headers
	 *
	 * @return ResponseInterface
	 *
	 * @throws GuzzleException
	 */
	public function sendUpdateSpaceRequest(
		string $user,
		string $password,
		$body,
		string $spaceId,
		string $xRequestId = '',
		array $headers = []
	): ResponseInterface {
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/$spaceId";
		$method = 'PATCH';

		return HttpRequestHelper::sendRequest($fullUrl, $xRequestId, $method, $user, $password, $headers, $body);
	}

	/**
	 * @Given /^user "([^"]*)" has created a space "([^"]*)" of type "([^"]*)" with quota "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $spaceType
	 * @param int $quota
	 *
	 * @return void
	 */
	public function userHasCreatedSpace(
		string $user,
		string $spaceName,
		string $spaceType,
		int $quota
	): void {
		$space = ["Name" => $spaceName, "driveType" => $spaceType, "quota" => ["total" => $quota]];
		$body = json_encode($space);
		$this->featureContext->setResponse(
			$this->sendCreateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body
			)
		);
		$this->featureContext->theHTTPStatusCodeShouldBe(
			201,
			"Expected response status code should be 201 (Created)"
		);
	}

	/**
	 * @When /^user "([^"]*)" has created a space "([^"]*)" with the default quota using the GraphApi$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 *
	 * @return void
	 *
	 * @throws GuzzleException
	 * @throws Exception
	 */
	public function theUserHasCreatedASpaceByDefaultUsingTheGraphApi(
		string $user,
		string $spaceName
	): void {
		$space = ["Name" => $spaceName];
		$body = json_encode($space, JSON_THROW_ON_ERROR);
		$this->featureContext->setResponse(
			$this->sendCreateSpaceRequest(
				$user,
				$this->featureContext->getPasswordForUser($user),
				$body
			)
		);
		$this->featureContext->theHTTPStatusCodeShouldBe(
			201,
			"Expected response status code should be 201 (Created)"
		);
	}

	/**
	 * @Given /^user "([^"]*)" has uploaded a file inside space "([^"]*)" with content "([^"]*)" to "([^"]*)"$/
	 *
	 * @param string $user
	 * @param string $spaceName
	 * @param string $fileContent
	 * @param string $destination
	 *
	 * @return void
	 */
	public function userHasUploadedFile(
		string $user,
		string $spaceName,
		string $fileContent,
		string $destination
	): void {
		$this->theUserListsAllHisAvailableSpacesUsingTheGraphApi($user);

		$space = $this->getSpaceByName($user, $spaceName);
		Assert::assertIsArray($space, "Space with name $spaceName not found");
		Assert::assertNotEmpty($space["root"]["webDavUrl"], "WebDavUrl for space with name $spaceName not found");

		$this->featureContext->setResponse(
			$this->sendPutRequestToUrl(
				$space["root"]["webDavUrl"] . "/" . $destination,
				$user,
				$this->featureContext->getPasswordForUser($user),
				"",
				[],
				$fileContent
			)
		);

		$this->featureContext->theHTTPStatusCodeShouldBeOr(201, 204);
	}

	/**
	 * @When /^user "([^"]*)" shares a space "([^"]*)" to user "([^"]*)" with role "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 * @param  string $userRecipient
	 * @param  string $role
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendShareSpaceRequest(
		string $user,
		string $spaceName,
		string $userRecipient,
		string $role
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$body = [
			"space_ref" => $space['id'],
			"shareType" => 7,
			"shareWith" => $userRecipient,
			"role" => $role // role overrides the permissions parameter
		];

		$fullUrl = $this->baseUrl . $this->ocsApiUrl;

		$this->featureContext->setResponse(
			HttpRequestHelper::post(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user),
				[],
				$body
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" shares the following entity "([^"]*)" inside of space "([^"]*)" with user "([^"]*)" with role "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $entity
	 * @param  string $spaceName
	 * @param  string $userRecipient
	 * @param  string $role
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendShareEntityInsideOfSpaceRequest(
		string $user,
		string $entity,
		string $spaceName,
		string $userRecipient,
		string $role
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$body = [
			"space_ref" => $space['id'] . "/" . $entity,
			"shareType" => 0,
			"shareWith" => $userRecipient,
			"role" => $role
		];

		$fullUrl = $this->baseUrl . $this->ocsApiUrl;

		$this->featureContext->setResponse(
			HttpRequestHelper::post(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user),
				[],
				$body
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" creates a public link share inside of space "([^"]*)" with settings:$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 * @param TableNode|null $table
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function createPublicLinkToEntityInsideOfSpaceRequest(
		string $user,
		string $spaceName,
		?TableNode $table
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$rows = $table->getRowsHash();

		$rows["path"] = \array_key_exists("path", $rows) ? $rows["path"] : null;
		$rows["shareType"] = \array_key_exists("shareType", $rows) ? $rows["shareType"] : null;
		$rows["permissions"] = \array_key_exists("permissions", $rows) ? $rows["permissions"] : null;
		$rows["password"] = \array_key_exists("password", $rows) ? $rows["password"] : null;
		$rows["name"] = \array_key_exists("name", $rows) ? $rows["name"] : null;
		$rows["expireDate"] = \array_key_exists("expireDate", $rows) ? $rows["expireDate"] : null;
		
		$body = [
			"space_ref" => $space['id'] . "/" . $rows["path"],
			"shareType" => $rows["shareType"],
			"permissions" => $rows["permissions"],
			"password" => $rows["password"],
			"name" => $rows["name"],
			"expireDate" => $rows["expireDate"]
		];

		$fullUrl = $this->baseUrl . $this->ocsApiUrl;

		$this->featureContext->setResponse(
			HttpRequestHelper::post(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user),
				[],
				$body
			)
		);
	}

	/**
	 * @Given /^user "([^"]*)" has shared a space "([^"]*)" to user "([^"]*)" with role "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 * @param  string $userRecipient
	 * @param  string $role
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function userHasSharedSpace(
		string $user,
		string $spaceName,
		string $userRecipient,
		string $role
	): void {
		$this->sendShareSpaceRequest($user, $spaceName, $userRecipient, $role);

		$expectedHTTPStatus = "200";
		$this->featureContext->theHTTPStatusCodeShouldBe(
			$expectedHTTPStatus,
			"Expected response status code should be $expectedHTTPStatus"
		);
		$expectedOCSStatus = "200";
		$this->ocsContext->theOCSStatusCodeShouldBe($expectedOCSStatus, "Expected OCS response status code $expectedOCSStatus");
	}

	/**
	 * @When /^user "([^"]*)" unshares a space "([^"]*)" to user "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 * @param  string $userRecipient
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendUnshareSpaceRequest(
		string $user,
		string $spaceName,
		string $userRecipient
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$fullUrl = $this->baseUrl . $this->ocsApiUrl . "/" . $space['id'] . "?shareWith=" . $userRecipient;

		$this->featureContext->setResponse(
			HttpRequestHelper::delete(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user)
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" removes the object "([^"]*)" from space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $object
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendRemoveObjectFromSpaceRequest(
		string $user,
		string $object,
		string $spaceName
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$spaceWebDavUrl = $space["root"]["webDavUrl"] . '/' . $object;
		$this->featureContext->setResponse(
			HttpRequestHelper::delete(
				$spaceWebDavUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user)
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" disables a space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendDisableSpaceRequest(
		string $user,
		string $spaceName
	): void {
		$space = $this->getSpaceByName($user, $spaceName);
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/" . $space["id"];
		$this->featureContext->setResponse(
			HttpRequestHelper::delete(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user)
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" has disabled a space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendUserHasDisabledSpaceRequest(
		string $user,
		string $spaceName
	): void {
		$this->sendDisableSpaceRequest($user, $spaceName);
		$expectedHTTPStatus = "204";
		$this->featureContext->theHTTPStatusCodeShouldBe(
			$expectedHTTPStatus,
			"Expected response status code should be $expectedHTTPStatus"
		);
	}

	/**
	 * @When /^user "([^"]*)" deletes a space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendDeleteSpaceRequest(
		string $user,
		string $spaceName
	): void {
		$header = ["Purge" => "T"];
		$space = $this->getSpaceByName($user, $spaceName);
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/" . $space["id"];

		$this->featureContext->setResponse(
			HttpRequestHelper::delete(
				$fullUrl,
				"",
				$user,
				$this->featureContext->getPasswordForUser($user),
				$header
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" restores a disabled space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 * @param  string $userWithManagerRights
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendRestoreSpaceRequest(
		string $user,
		string $spaceName,
		string $userWithManagerRights = ''
	): void {
		if (!empty($userWithManagerRights)) {
			$space = $this->getSpaceByName($userWithManagerRights, $spaceName);
		} else {
			$space = $this->getSpaceByName($user, $spaceName);
		}
		$header = ["restore" => true];
		$body = '{}';
		$fullUrl = $this->baseUrl . "/graph/v1.0/drives/" . $space["id"];
		$this->featureContext->setResponse(
			HttpRequestHelper::sendRequest(
				$fullUrl,
				"",
				'PATCH',
				$user,
				$this->featureContext->getPasswordForUser($user),
				$header,
				$body
			)
		);
	}

	/**
	 * @When /^user "([^"]*)" restores a disabled space "([^"]*)" without manager rights$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function sendRestoreSpaceWithoutRightsRequest(
		string $user,
		string $spaceName
	): void {
		$this->sendRestoreSpaceRequest($user, $spaceName, $this->featureContext->getAdminUsername());
	}

	/**
	 * @When /^user "([^"]*)" has restored a disabled space "([^"]*)"$/
	 *
	 * @param  string $user
	 * @param  string $spaceName
	 *
	 * @return void
	 * @throws GuzzleException
	 */
	public function userHasRestoredSpaceRequest(
		string $user,
		string $spaceName
	): void {
		$this->sendRestoreSpaceRequest($user, $spaceName);
		$expectedHTTPStatus = "200";
		$this->featureContext->theHTTPStatusCodeShouldBe(
			$expectedHTTPStatus,
			"Expected response status code should be $expectedHTTPStatus"
		);
	}
}
