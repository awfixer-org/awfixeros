/*
    Copyright (C) 2004, 2005, 2007 Nikolas Zimmermann <zimmermann@kde.org>
                  2004, 2005, 2010 Rob Buis <buis@kde.org>
    Copyright (C) Research In Motion Limited 2010. All rights reserved.
    Copyright (C) 2025 Samuel Weinig <sam@webkit.org>

    Based on khtml code by:
    Copyright (C) 1999 Antti Koivisto (koivisto@kde.org)
    Copyright (C) 1999-2003 Lars Knoll (knoll@kde.org)
    Copyright (C) 2002-2003 Dirk Mueller (mueller@kde.org)
    Copyright (C) 2002 Apple Inc. All rights reserved.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "config.h"
#include "SVGRenderStyle.h"

#include "RenderStyleDifference.h"
#include "StyleComputedStyle+InitialInlines.h"
#include "StylePrimitiveKeyword+Logging.h"
#include "StylePrimitiveNumericTypes+Logging.h"
#include "WebAnimationTypes.h"
#include <wtf/NeverDestroyed.h>

namespace WebCore {

static const SVGRenderStyle& defaultSVGStyle()
{
    static NeverDestroyed<DataRef<SVGRenderStyle>> style(SVGRenderStyle::createDefaultStyle());
    return *style.get();
}

DEFINE_ALLOCATOR_WITH_HEAP_IDENTIFIER(SVGRenderStyle);

Ref<SVGRenderStyle> SVGRenderStyle::createDefaultStyle()
{
    return adoptRef(*new SVGRenderStyle(CreateDefault));
}

SVGRenderStyle::SVGRenderStyle()
    : fillData(defaultSVGStyle().fillData)
    , strokeData(defaultSVGStyle().strokeData)
    , inheritedResourceData(defaultSVGStyle().inheritedResourceData)
    , stopData(defaultSVGStyle().stopData)
    , miscData(defaultSVGStyle().miscData)
    , layoutData(defaultSVGStyle().layoutData)
{
    setBitDefaults();
}

SVGRenderStyle::SVGRenderStyle(CreateDefaultType)
    : fillData(StyleFillData::create())
    , strokeData(StyleStrokeData::create())
    , inheritedResourceData(StyleInheritedResourceData::create())
    , stopData(StyleStopData::create())
    , miscData(StyleMiscData::create())
    , layoutData(StyleLayoutData::create())
{
    setBitDefaults();
}

inline SVGRenderStyle::SVGRenderStyle(const SVGRenderStyle& other)
    : RefCounted<SVGRenderStyle>()
    , inheritedFlags(other.inheritedFlags)
    , nonInheritedFlags(other.nonInheritedFlags)
    , fillData(other.fillData)
    , strokeData(other.strokeData)
    , inheritedResourceData(other.inheritedResourceData)
    , stopData(other.stopData)
    , miscData(other.miscData)
    , layoutData(other.layoutData)
{
    ASSERT(other == *this, "SVGRenderStyle should be properly copied.");
}

Ref<SVGRenderStyle> SVGRenderStyle::copy() const
{
    return adoptRef(*new SVGRenderStyle(*this));
}

SVGRenderStyle::~SVGRenderStyle() = default;

bool SVGRenderStyle::operator==(const SVGRenderStyle& other) const
{
    return inheritedEqual(other) && nonInheritedEqual(other);
}

void SVGRenderStyle::setBitDefaults()
{
    inheritedFlags.clipRule = static_cast<unsigned>(Style::ComputedStyle::initialClipRule());
    inheritedFlags.fillRule = static_cast<unsigned>(Style::ComputedStyle::initialFillRule());
    inheritedFlags.shapeRendering = static_cast<unsigned>(Style::ComputedStyle::initialShapeRendering());
    inheritedFlags.textAnchor = static_cast<unsigned>(Style::ComputedStyle::initialTextAnchor());
    inheritedFlags.colorInterpolation = static_cast<unsigned>(Style::ComputedStyle::initialColorInterpolation());
    inheritedFlags.colorInterpolationFilters = static_cast<unsigned>(Style::ComputedStyle::initialColorInterpolationFilters());
    inheritedFlags.glyphOrientationHorizontal = static_cast<unsigned>(Style::ComputedStyle::initialGlyphOrientationHorizontal());
    inheritedFlags.glyphOrientationVertical = static_cast<unsigned>(Style::ComputedStyle::initialGlyphOrientationVertical());

    nonInheritedFlags.alignmentBaseline = static_cast<unsigned>(Style::ComputedStyle::initialAlignmentBaseline());
    nonInheritedFlags.dominantBaseline = static_cast<unsigned>(Style::ComputedStyle::initialDominantBaseline());
    nonInheritedFlags.vectorEffect = static_cast<unsigned>(Style::ComputedStyle::initialVectorEffect());
    nonInheritedFlags.bufferedRendering = static_cast<unsigned>(Style::ComputedStyle::initialBufferedRendering());
    nonInheritedFlags.maskType = static_cast<unsigned>(Style::ComputedStyle::initialMaskType());
}

bool SVGRenderStyle::inheritedEqual(const SVGRenderStyle& other) const
{
    return fillData == other.fillData
        && strokeData == other.strokeData
        && inheritedResourceData == other.inheritedResourceData
        && inheritedFlags == other.inheritedFlags;
}

bool SVGRenderStyle::nonInheritedEqual(const SVGRenderStyle& other) const
{
    return stopData == other.stopData
        && miscData == other.miscData
        && layoutData == other.layoutData
        && nonInheritedFlags == other.nonInheritedFlags;
}

void SVGRenderStyle::inheritFrom(const SVGRenderStyle& other)
{
    fillData = other.fillData;
    strokeData = other.strokeData;
    inheritedResourceData = other.inheritedResourceData;

    inheritedFlags = other.inheritedFlags;
}

void SVGRenderStyle::copyNonInheritedFrom(const SVGRenderStyle& other)
{
    nonInheritedFlags = other.nonInheritedFlags;
    stopData = other.stopData;
    miscData = other.miscData;
    layoutData = other.layoutData;
}

#if !LOG_DISABLED

void SVGRenderStyle::InheritedFlags::dumpDifferences(TextStream& ts, const SVGRenderStyle::InheritedFlags& other) const
{
    LOG_IF_DIFFERENT_WITH_CAST(ShapeRendering, shapeRendering);
    LOG_IF_DIFFERENT_WITH_CAST(WindRule, clipRule);
    LOG_IF_DIFFERENT_WITH_CAST(WindRule, fillRule);
    LOG_IF_DIFFERENT_WITH_CAST(TextAnchor, textAnchor);
    LOG_IF_DIFFERENT_WITH_CAST(ColorInterpolation, colorInterpolation);
    LOG_IF_DIFFERENT_WITH_CAST(ColorInterpolation, colorInterpolationFilters);
    LOG_IF_DIFFERENT_WITH_CAST(Style::SVGGlyphOrientationHorizontal, glyphOrientationHorizontal);
    LOG_IF_DIFFERENT_WITH_CAST(Style::SVGGlyphOrientationVertical, glyphOrientationVertical);
}

void SVGRenderStyle::NonInheritedFlags::dumpDifferences(TextStream& ts, const SVGRenderStyle::NonInheritedFlags& other) const
{
    LOG_IF_DIFFERENT_WITH_CAST(AlignmentBaseline, alignmentBaseline);
    LOG_IF_DIFFERENT_WITH_CAST(DominantBaseline, dominantBaseline);
    LOG_IF_DIFFERENT_WITH_CAST(VectorEffect, vectorEffect);
    LOG_IF_DIFFERENT_WITH_CAST(BufferedRendering, bufferedRendering);
    LOG_IF_DIFFERENT_WITH_CAST(MaskType, maskType);
}

void SVGRenderStyle::dumpDifferences(TextStream& ts, const SVGRenderStyle& other) const
{
    inheritedFlags.dumpDifferences(ts, other.inheritedFlags);
    nonInheritedFlags.dumpDifferences(ts, other.nonInheritedFlags);

    fillData->dumpDifferences(ts, other.fillData);
    strokeData->dumpDifferences(ts, other.strokeData);
    inheritedResourceData->dumpDifferences(ts, other.inheritedResourceData);

    stopData->dumpDifferences(ts, other.stopData);
    miscData->dumpDifferences(ts, other.miscData);
    layoutData->dumpDifferences(ts, other.layoutData);
}
#endif

} // namespace WebCore
