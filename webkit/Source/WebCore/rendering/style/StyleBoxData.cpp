/*
 * Copyright (C) 1999 Antti Koivisto (koivisto@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
 * Copyright (C) 2025 Samuel Weinig <sam@webkit.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

#include "config.h"
#include "StyleBoxData.h"

#include "RenderStyleDifference.h"
#include "StyleComputedStyle+InitialInlines.h"
#include "StylePrimitiveKeyword+Logging.h"
#include "StylePrimitiveNumericTypes+Logging.h"

namespace WebCore {

struct SameSizeAsStyleBoxData : public RefCounted<SameSizeAsStyleBoxData> {
    Style::LengthWrapperData length[6];
    Style::VerticalAlign verticalAlign;
    uint8_t bitfield;
    int m_zIndex[2];
};
static_assert(sizeof(StyleBoxData) == sizeof(SameSizeAsStyleBoxData), "StyleBoxData should not grow");

DEFINE_ALLOCATOR_WITH_HEAP_IDENTIFIER(StyleBoxData);

StyleBoxData::StyleBoxData()
    : width(Style::ComputedStyle::initialWidth())
    , height(Style::ComputedStyle::initialHeight())
    , minWidth(Style::ComputedStyle::initialMinWidth())
    , minHeight(Style::ComputedStyle::initialMinHeight())
    , maxWidth(Style::ComputedStyle::initialMaxWidth())
    , maxHeight(Style::ComputedStyle::initialMaxHeight())
    , verticalAlign(Style::ComputedStyle::initialVerticalAlign())
    , hasAutoSpecifiedZIndex(static_cast<uint8_t>(Style::ComputedStyle::initialSpecifiedZIndex().m_isAuto))
    , hasAutoUsedZIndex(static_cast<uint8_t>(Style::ComputedStyle::initialUsedZIndex().m_isAuto))
    , boxSizing(static_cast<uint8_t>(BoxSizing::ContentBox))
    , boxDecorationBreak(static_cast<uint8_t>(BoxDecorationBreak::Slice))
    , specifiedZIndexValue(Style::ComputedStyle::initialSpecifiedZIndex().m_value)
    , usedZIndexValue(Style::ComputedStyle::initialUsedZIndex().m_value)
{
}

inline StyleBoxData::StyleBoxData(const StyleBoxData& o)
    : RefCounted<StyleBoxData>()
    , width(o.width)
    , height(o.height)
    , minWidth(o.minWidth)
    , minHeight(o.minHeight)
    , maxWidth(o.maxWidth)
    , maxHeight(o.maxHeight)
    , verticalAlign(o.verticalAlign)
    , hasAutoSpecifiedZIndex(o.hasAutoSpecifiedZIndex)
    , hasAutoUsedZIndex(o.hasAutoUsedZIndex)
    , boxSizing(o.boxSizing)
    , boxDecorationBreak(o.boxDecorationBreak)
    , specifiedZIndexValue(o.specifiedZIndexValue)
    , usedZIndexValue(o.usedZIndexValue)
{
}

Ref<StyleBoxData> StyleBoxData::copy() const
{
    return adoptRef(*new StyleBoxData(*this));
}

bool StyleBoxData::operator==(const StyleBoxData& o) const
{
    return width == o.width
        && height == o.height
        && minWidth == o.minWidth
        && minHeight == o.minHeight
        && maxWidth == o.maxWidth
        && maxHeight == o.maxHeight
        && verticalAlign == o.verticalAlign
        && usedZIndexValue == o.usedZIndexValue
        && hasAutoUsedZIndex == o.hasAutoUsedZIndex
        && boxSizing == o.boxSizing
        && boxDecorationBreak == o.boxDecorationBreak
        && specifiedZIndexValue == o.specifiedZIndexValue
        && hasAutoSpecifiedZIndex == o.hasAutoSpecifiedZIndex;
}

#if !LOG_DISABLED
void StyleBoxData::dumpDifferences(TextStream& ts, const StyleBoxData& other) const
{
    LOG_IF_DIFFERENT(width);
    LOG_IF_DIFFERENT(height);

    LOG_IF_DIFFERENT(minWidth);
    LOG_IF_DIFFERENT(minHeight);

    LOG_IF_DIFFERENT(maxWidth);
    LOG_IF_DIFFERENT(maxHeight);

    LOG_IF_DIFFERENT(verticalAlign);

    LOG_IF_DIFFERENT_WITH_CAST(bool, hasAutoSpecifiedZIndex);
    LOG_IF_DIFFERENT_WITH_CAST(bool, hasAutoUsedZIndex);

    LOG_IF_DIFFERENT_WITH_CAST(BoxSizing, boxSizing);
    LOG_IF_DIFFERENT_WITH_CAST(BoxDecorationBreak, boxDecorationBreak);

    LOG_IF_DIFFERENT(specifiedZIndexValue);
    LOG_IF_DIFFERENT(usedZIndexValue);
}
#endif

} // namespace WebCore
