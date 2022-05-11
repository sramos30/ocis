<?php declare(strict_types=1);
/**
 * ownCloud
 *
 * @author Phil Davis <phil@jankaritech.com>
 * @copyright Copyright (c) 2020 Phil Davis phil@jankaritech.com
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

$pathToCore = \getenv('PATH_TO_CORE');
if ($pathToCore === false) {
	$pathToCore = "../core";
}

require_once $pathToCore . '/tests/acceptance/features/bootstrap/bootstrap.php';

$classLoader = new \Composer\Autoload\ClassLoader();
$classLoader->addPsr4(
	"",
	$pathToCore . "/tests/acceptance/features/bootstrap",
	true
);

$classLoader->register();
