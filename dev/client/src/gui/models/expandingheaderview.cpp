/*
 * Copyright (C) by Hannah von Reth <hannah.vonreth@owncloud.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */
#include "expandingheaderview.h"
#include "models.h"

#include "configfile.h"

#include <QApplication>
#include <QDebug>
#include <QMenu>
#include <QScopedValueRollback>

using namespace OCC;

ExpandingHeaderView::ExpandingHeaderView(const QString &objectName, QWidget *parent)
    : QHeaderView(Qt::Horizontal, parent)
{
    setSectionsClickable(true);
    setHighlightSections(true);

    connect(this, &QHeaderView::sectionCountChanged, this, &ExpandingHeaderView::resizeColumns);

    setObjectName(objectName);
    ConfigFile cfg;
    cfg.restoreGeometryHeader(this);

    connect(qApp, &QApplication::aboutToQuit, this, [this] {
        ConfigFile cfg;
        cfg.saveGeometryHeader(this);
    });
}

int ExpandingHeaderView::expandingColumn() const
{
    return _expandingColumn;
}

void ExpandingHeaderView::setExpandingColumn(int newExpandingColumn)
{
    _expandingColumn = newExpandingColumn;
}

void ExpandingHeaderView::resizeEvent(QResizeEvent *event)
{
    QHeaderView::resizeEvent(event);
    resizeColumns();
}

void ExpandingHeaderView::resizeColumns(bool reset)
{
    int availableWidth = width();
    const auto defaultSize = defaultSectionSize();
    for (int i = 0; i < count(); ++i) {
        if (i == _expandingColumn || isSectionHidden(i)) {
            continue;
        }
        if (reset) {
            resizeSection(i, defaultSize);
        }
        availableWidth -= sectionSize(i);
    }
    resizeSection(_expandingColumn, availableWidth);
}

void ExpandingHeaderView::addResetActionToMenu(QMenu *menu)
{
    menu->addAction(tr("Reset column sizes"), this, [this] { resizeColumns(true); });
}
