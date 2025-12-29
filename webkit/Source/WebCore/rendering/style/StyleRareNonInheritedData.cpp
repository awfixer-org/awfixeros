/*
 * Copyright (C) 1999 Antti Koivisto (koivisto@kde.org)
 * Copyright (C) 2004-2017 Apple Inc. All rights reserved.
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
 */

#include "config.h"
#include "StyleRareNonInheritedData.h"

#include "RenderStyleDifference.h"
#include "StyleComputedStyle+InitialInlines.h"
#include "StylePrimitiveKeyword+Logging.h"
#include "StylePrimitiveNumericTypes+Logging.h"

namespace WebCore {

DEFINE_ALLOCATOR_WITH_HEAP_IDENTIFIER(StyleRareNonInheritedData);

StyleRareNonInheritedData::StyleRareNonInheritedData()
    : containIntrinsicWidth(Style::ComputedStyle::initialContainIntrinsicWidth())
    , containIntrinsicHeight(Style::ComputedStyle::initialContainIntrinsicHeight())
    , lineClamp(Style::ComputedStyle::initialLineClamp())
    , zoom(Style::ComputedStyle::initialZoom())
    , maxLines(Style::ComputedStyle::initialMaxLines())
    , touchAction(Style::ComputedStyle::initialTouchAction())
    , initialLetter(Style::ComputedStyle::initialInitialLetter())
    , marquee(StyleMarqueeData::create())
    , backdropFilter(StyleBackdropFilterData::create())
    , grid(StyleGridData::create())
    , gridItem(StyleGridItemData::create())
    , maskBorder(StyleMaskBorderData::create())
    , clip(Style::ComputedStyle::initialClip())
    // scrollMargin
    // scrollPadding
    // counterDirectives
    , willChange(Style::ComputedStyle::initialWillChange())
    , boxReflect(Style::ComputedStyle::initialBoxReflect())
    , pageSize(Style::ComputedStyle::initialPageSize())
    , shapeOutside(Style::ComputedStyle::initialShapeOutside())
    , shapeMargin(Style::ComputedStyle::initialShapeMargin())
    , shapeImageThreshold(Style::ComputedStyle::initialShapeImageThreshold())
    , perspective(Style::ComputedStyle::initialPerspective())
    , perspectiveOrigin({ Style::ComputedStyle::initialPerspectiveOriginX(), Style::ComputedStyle::initialPerspectiveOriginY() })
    , clipPath(Style::ComputedStyle::initialClipPath())
    , customProperties(Style::CustomPropertyData::create())
    // customPaintWatchedProperties
    , rotate(Style::ComputedStyle::initialRotate())
    , scale(Style::ComputedStyle::initialScale())
    , translate(Style::ComputedStyle::initialTranslate())
    , containerNames(Style::ComputedStyle::initialContainerNames())
    , viewTransitionClasses(Style::ComputedStyle::initialViewTransitionClasses())
    , viewTransitionName(Style::ComputedStyle::initialViewTransitionName())
    , columnGap(Style::ComputedStyle::initialColumnGap())
    , rowGap(Style::ComputedStyle::initialRowGap())
    , itemTolerance(Style::ComputedStyle::initialItemTolerance())
    , offsetPath(Style::ComputedStyle::initialOffsetPath())
    , offsetDistance(Style::ComputedStyle::initialOffsetDistance())
    , offsetPosition(Style::ComputedStyle::initialOffsetPosition())
    , offsetAnchor(Style::ComputedStyle::initialOffsetAnchor())
    , offsetRotate(Style::ComputedStyle::initialOffsetRotate())
    , textDecorationColor(Style::ComputedStyle::initialTextDecorationColor())
    , textDecorationThickness(Style::ComputedStyle::initialTextDecorationThickness())
    // scrollTimelines
    , scrollTimelineAxes(Style::ComputedStyle::initialScrollTimelineAxes())
    , scrollTimelineNames(Style::ComputedStyle::initialScrollTimelineNames())
    // viewTimelines
    , viewTimelineInsets(Style::ComputedStyle::initialViewTimelineInsets())
    , viewTimelineAxes(Style::ComputedStyle::initialViewTimelineAxes())
    , viewTimelineNames(Style::ComputedStyle::initialViewTimelineNames())
    , timelineScope(Style::ComputedStyle::initialTimelineScope())
    , scrollbarGutter(Style::ComputedStyle::initialScrollbarGutter())
    , scrollSnapType(Style::ComputedStyle::initialScrollSnapType())
    , scrollSnapAlign(Style::ComputedStyle::initialScrollSnapAlign())
    , pseudoElementNameArgument(nullAtom())
    , anchorNames(Style::ComputedStyle::initialAnchorNames())
    , anchorScope(Style::ComputedStyle::initialAnchorScope())
    , positionAnchor(Style::ComputedStyle::initialPositionAnchor())
    , positionArea(Style::ComputedStyle::initialPositionArea())
    , positionTryFallbacks(Style::ComputedStyle::initialPositionTryFallbacks())
    , usedPositionOptionIndex()
    , blockStepSize(Style::ComputedStyle::initialBlockStepSize())
    , blockStepAlign(static_cast<unsigned>(Style::ComputedStyle::initialBlockStepAlign()))
    , blockStepInsert(static_cast<unsigned>(Style::ComputedStyle::initialBlockStepInsert()))
    , blockStepRound(static_cast<unsigned>(Style::ComputedStyle::initialBlockStepRound()))
    , overscrollBehaviorX(static_cast<unsigned>(Style::ComputedStyle::initialOverscrollBehaviorX()))
    , overscrollBehaviorY(static_cast<unsigned>(Style::ComputedStyle::initialOverscrollBehaviorY()))
    , transformStyle3D(static_cast<unsigned>(Style::ComputedStyle::initialTransformStyle3D()))
    , transformStyleForcedToFlat(false)
    , backfaceVisibility(static_cast<unsigned>(Style::ComputedStyle::initialBackfaceVisibility()))
    , scrollBehavior(static_cast<unsigned>(Style::ComputedStyle::initialScrollBehavior()))
    , textDecorationStyle(static_cast<unsigned>(Style::ComputedStyle::initialTextDecorationStyle()))
    , textGroupAlign(static_cast<unsigned>(Style::ComputedStyle::initialTextGroupAlign()))
    , contentVisibility(static_cast<unsigned>(Style::ComputedStyle::initialContentVisibility()))
    , effectiveBlendMode(static_cast<unsigned>(Style::ComputedStyle::initialBlendMode()))
    , isolation(static_cast<unsigned>(Style::ComputedStyle::initialIsolation()))
    , inputSecurity(static_cast<unsigned>(Style::ComputedStyle::initialInputSecurity()))
#if ENABLE(APPLE_PAY)
    , applePayButtonStyle(static_cast<unsigned>(Style::ComputedStyle::initialApplePayButtonStyle()))
    , applePayButtonType(static_cast<unsigned>(Style::ComputedStyle::initialApplePayButtonType()))
#endif
    , breakBefore(static_cast<unsigned>(Style::ComputedStyle::initialBreakBefore()))
    , breakAfter(static_cast<unsigned>(Style::ComputedStyle::initialBreakAfter()))
    , breakInside(static_cast<unsigned>(Style::ComputedStyle::initialBreakInside()))
    , containerType(static_cast<unsigned>(Style::ComputedStyle::initialContainerType()))
    , textBoxTrim(static_cast<unsigned>(Style::ComputedStyle::initialTextBoxTrim()))
    , overflowAnchor(static_cast<unsigned>(Style::ComputedStyle::initialOverflowAnchor()))
    , positionTryOrder(static_cast<unsigned>(Style::ComputedStyle::initialPositionTryOrder()))
    , positionVisibility(Style::ComputedStyle::initialPositionVisibility().toRaw())
    , fieldSizing(static_cast<unsigned>(Style::ComputedStyle::initialFieldSizing()))
    , nativeAppearanceDisabled(static_cast<unsigned>(false))
#if HAVE(CORE_MATERIAL)
    , appleVisualEffect(static_cast<unsigned>(Style::ComputedStyle::initialAppleVisualEffect()))
#endif
    , scrollbarWidth(static_cast<unsigned>(Style::ComputedStyle::initialScrollbarWidth()))
    , usesAnchorFunctions(false)
    , anchorFunctionScrollCompensatedAxes(0)
    , isPopoverInvoker(false)
    , useSVGZoomRulesForLength(false)
    , marginTrim(Style::ComputedStyle::initialMarginTrim().toRaw())
    , contain(Style::ComputedStyle::initialContain().toRaw())
    , overflowContinue(static_cast<unsigned>(Style::ComputedStyle::initialOverflowContinue()))
    , scrollSnapStop(static_cast<unsigned>(Style::ComputedStyle::initialScrollSnapStop()))
{
}

inline StyleRareNonInheritedData::StyleRareNonInheritedData(const StyleRareNonInheritedData& o)
    : RefCounted<StyleRareNonInheritedData>()
    , containIntrinsicWidth(o.containIntrinsicWidth)
    , containIntrinsicHeight(o.containIntrinsicHeight)
    , lineClamp(o.lineClamp)
    , zoom(o.zoom)
    , maxLines(o.maxLines)
    , touchAction(o.touchAction)
    , initialLetter(o.initialLetter)
    , marquee(o.marquee)
    , backdropFilter(o.backdropFilter)
    , grid(o.grid)
    , gridItem(o.gridItem)
    , maskBorder(o.maskBorder)
    , clip(o.clip)
    , scrollMargin(o.scrollMargin)
    , scrollPadding(o.scrollPadding)
    , counterDirectives(o.counterDirectives)
    , willChange(o.willChange)
    , boxReflect(o.boxReflect)
    , pageSize(o.pageSize)
    , shapeOutside(o.shapeOutside)
    , shapeMargin(o.shapeMargin)
    , shapeImageThreshold(o.shapeImageThreshold)
    , perspective(o.perspective)
    , perspectiveOrigin(o.perspectiveOrigin)
    , clipPath(o.clipPath)
    , customProperties(o.customProperties)
    , customPaintWatchedProperties(o.customPaintWatchedProperties)
    , rotate(o.rotate)
    , scale(o.scale)
    , translate(o.translate)
    , containerNames(o.containerNames)
    , viewTransitionClasses(o.viewTransitionClasses)
    , viewTransitionName(o.viewTransitionName)
    , columnGap(o.columnGap)
    , rowGap(o.rowGap)
    , itemTolerance(o.itemTolerance)
    , offsetPath(o.offsetPath)
    , offsetDistance(o.offsetDistance)
    , offsetPosition(o.offsetPosition)
    , offsetAnchor(o.offsetAnchor)
    , offsetRotate(o.offsetRotate)
    , textDecorationColor(o.textDecorationColor)
    , textDecorationThickness(o.textDecorationThickness)
    , scrollTimelines(o.scrollTimelines)
    , scrollTimelineAxes(o.scrollTimelineAxes)
    , scrollTimelineNames(o.scrollTimelineNames)
    , viewTimelines(o.viewTimelines)
    , viewTimelineInsets(o.viewTimelineInsets)
    , viewTimelineAxes(o.viewTimelineAxes)
    , viewTimelineNames(o.viewTimelineNames)
    , timelineScope(o.timelineScope)
    , scrollbarGutter(o.scrollbarGutter)
    , scrollSnapType(o.scrollSnapType)
    , scrollSnapAlign(o.scrollSnapAlign)
    , pseudoElementNameArgument(o.pseudoElementNameArgument)
    , anchorNames(o.anchorNames)
    , anchorScope(o.anchorScope)
    , positionAnchor(o.positionAnchor)
    , positionArea(o.positionArea)
    , positionTryFallbacks(o.positionTryFallbacks)
    , usedPositionOptionIndex(o.usedPositionOptionIndex)
    , blockStepSize(o.blockStepSize)
    , blockStepAlign(o.blockStepAlign)
    , blockStepInsert(o.blockStepInsert)
    , blockStepRound(o.blockStepRound)
    , overscrollBehaviorX(o.overscrollBehaviorX)
    , overscrollBehaviorY(o.overscrollBehaviorY)
    , transformStyle3D(o.transformStyle3D)
    , transformStyleForcedToFlat(o.transformStyleForcedToFlat)
    , backfaceVisibility(o.backfaceVisibility)
    , scrollBehavior(o.scrollBehavior)
    , textDecorationStyle(o.textDecorationStyle)
    , textGroupAlign(o.textGroupAlign)
    , contentVisibility(o.contentVisibility)
    , effectiveBlendMode(o.effectiveBlendMode)
    , isolation(o.isolation)
    , inputSecurity(o.inputSecurity)
#if ENABLE(APPLE_PAY)
    , applePayButtonStyle(o.applePayButtonStyle)
    , applePayButtonType(o.applePayButtonType)
#endif
    , breakBefore(o.breakBefore)
    , breakAfter(o.breakAfter)
    , breakInside(o.breakInside)
    , containerType(o.containerType)
    , textBoxTrim(o.textBoxTrim)
    , overflowAnchor(o.overflowAnchor)
    , positionTryOrder(o.positionTryOrder)
    , positionVisibility(o.positionVisibility)
    , fieldSizing(o.fieldSizing)
    , nativeAppearanceDisabled(o.nativeAppearanceDisabled)
#if HAVE(CORE_MATERIAL)
    , appleVisualEffect(o.appleVisualEffect)
#endif
    , scrollbarWidth(o.scrollbarWidth)
    , usesAnchorFunctions(o.usesAnchorFunctions)
    , anchorFunctionScrollCompensatedAxes(o.anchorFunctionScrollCompensatedAxes)
    , isPopoverInvoker(o.isPopoverInvoker)
    , useSVGZoomRulesForLength(o.useSVGZoomRulesForLength)
    , marginTrim(o.marginTrim)
    , contain(o.contain)
    , overflowContinue(o.overflowContinue)
    , scrollSnapStop(o.scrollSnapStop)
{
}

Ref<StyleRareNonInheritedData> StyleRareNonInheritedData::copy() const
{
    return adoptRef(*new StyleRareNonInheritedData(*this));
}

StyleRareNonInheritedData::~StyleRareNonInheritedData() = default;

bool StyleRareNonInheritedData::operator==(const StyleRareNonInheritedData& o) const
{
    return containIntrinsicWidth == o.containIntrinsicWidth
        && containIntrinsicHeight == o.containIntrinsicHeight
        && lineClamp == o.lineClamp
        && zoom == o.zoom
        && maxLines == o.maxLines
        && touchAction == o.touchAction
        && initialLetter == o.initialLetter
        && marquee == o.marquee
        && backdropFilter == o.backdropFilter
        && grid == o.grid
        && gridItem == o.gridItem
        && maskBorder == o.maskBorder
        && clip == o.clip
        && scrollMargin == o.scrollMargin
        && scrollPadding == o.scrollPadding
        && counterDirectives == o.counterDirectives
        && willChange == o.willChange
        && boxReflect == o.boxReflect
        && pageSize == o.pageSize
        && shapeOutside == o.shapeOutside
        && shapeMargin == o.shapeMargin
        && shapeImageThreshold == o.shapeImageThreshold
        && perspective == o.perspective
        && perspectiveOrigin == o.perspectiveOrigin
        && clipPath == o.clipPath
        && textDecorationColor == o.textDecorationColor
        && customProperties == o.customProperties
        && customPaintWatchedProperties == o.customPaintWatchedProperties
        && rotate == o.rotate
        && scale == o.scale
        && translate == o.translate
        && containerNames == o.containerNames
        && columnGap == o.columnGap
        && rowGap == o.rowGap
        && itemTolerance == o.itemTolerance
        && offsetPath == o.offsetPath
        && offsetDistance == o.offsetDistance
        && offsetPosition == o.offsetPosition
        && offsetAnchor == o.offsetAnchor
        && offsetRotate == o.offsetRotate
        && textDecorationThickness == o.textDecorationThickness
        && scrollTimelines == o.scrollTimelines
        && scrollTimelineAxes == o.scrollTimelineAxes
        && scrollTimelineNames == o.scrollTimelineNames
        && viewTimelines == o.viewTimelines
        && viewTimelineInsets == o.viewTimelineInsets
        && viewTimelineAxes == o.viewTimelineAxes
        && viewTimelineNames == o.viewTimelineNames
        && timelineScope == o.timelineScope
        && scrollbarGutter == o.scrollbarGutter
        && scrollSnapType == o.scrollSnapType
        && scrollSnapAlign == o.scrollSnapAlign
        && pseudoElementNameArgument == o.pseudoElementNameArgument
        && anchorNames == o.anchorNames
        && anchorScope == o.anchorScope
        && positionAnchor == o.positionAnchor
        && positionArea == o.positionArea
        && positionTryFallbacks == o.positionTryFallbacks
        && usedPositionOptionIndex == o.usedPositionOptionIndex
        && blockStepSize == o.blockStepSize
        && blockStepAlign == o.blockStepAlign
        && blockStepInsert == o.blockStepInsert
        && blockStepRound == o.blockStepRound
        && overscrollBehaviorX == o.overscrollBehaviorX
        && overscrollBehaviorY == o.overscrollBehaviorY
        && transformStyle3D == o.transformStyle3D
        && transformStyleForcedToFlat == o.transformStyleForcedToFlat
        && backfaceVisibility == o.backfaceVisibility
        && scrollBehavior == o.scrollBehavior
        && textDecorationStyle == o.textDecorationStyle
        && textGroupAlign == o.textGroupAlign
        && effectiveBlendMode == o.effectiveBlendMode
        && isolation == o.isolation
        && inputSecurity == o.inputSecurity
#if ENABLE(APPLE_PAY)
        && applePayButtonStyle == o.applePayButtonStyle
        && applePayButtonType == o.applePayButtonType
#endif
        && contentVisibility == o.contentVisibility
        && breakAfter == o.breakAfter
        && breakBefore == o.breakBefore
        && breakInside == o.breakInside
        && containerType == o.containerType
        && textBoxTrim == o.textBoxTrim
        && overflowAnchor == o.overflowAnchor
        && viewTransitionClasses == o.viewTransitionClasses
        && viewTransitionName == o.viewTransitionName
        && positionTryOrder == o.positionTryOrder
        && positionVisibility == o.positionVisibility
        && fieldSizing == o.fieldSizing
        && nativeAppearanceDisabled == o.nativeAppearanceDisabled
#if HAVE(CORE_MATERIAL)
        && appleVisualEffect == o.appleVisualEffect
#endif
        && scrollbarWidth == o.scrollbarWidth
        && usesAnchorFunctions == o.usesAnchorFunctions
        && anchorFunctionScrollCompensatedAxes == o.anchorFunctionScrollCompensatedAxes
        && isPopoverInvoker == o.isPopoverInvoker
        && useSVGZoomRulesForLength == o.useSVGZoomRulesForLength
        && marginTrim == o.marginTrim
        && contain == o.contain
        && overflowContinue == o.overflowContinue
        && scrollSnapStop == o.scrollSnapStop;
}

Style::Contain StyleRareNonInheritedData::usedContain() const
{
    auto result = Style::Contain::fromRaw(contain);

    switch (static_cast<ContainerType>(containerType)) {
    case ContainerType::Normal:
        break;
    case ContainerType::Size:
        result.add({ Style::ContainValue::Style, Style::ContainValue::Size });
        break;
    case ContainerType::InlineSize:
        result.add({ Style::ContainValue::Style, Style::ContainValue::InlineSize });
        break;
    };

    return result;
}

#if !LOG_DISABLED
void StyleRareNonInheritedData::dumpDifferences(TextStream& ts, const StyleRareNonInheritedData& other) const
{
    marquee->dumpDifferences(ts, other.marquee);
    backdropFilter->dumpDifferences(ts, other.backdropFilter);
    grid->dumpDifferences(ts, other.grid);
    gridItem->dumpDifferences(ts, other.gridItem);
    maskBorder->dumpDifferences(ts, other.maskBorder);

    LOG_IF_DIFFERENT(containIntrinsicWidth);
    LOG_IF_DIFFERENT(containIntrinsicHeight);

    LOG_IF_DIFFERENT(lineClamp);

    LOG_IF_DIFFERENT(zoom);

    LOG_IF_DIFFERENT(maxLines);

    LOG_IF_DIFFERENT(touchAction);

    LOG_IF_DIFFERENT(initialLetter);

    LOG_IF_DIFFERENT(clip);
    LOG_IF_DIFFERENT(scrollMargin);
    LOG_IF_DIFFERENT(scrollPadding);

    LOG_IF_DIFFERENT(counterDirectives);

    LOG_IF_DIFFERENT(willChange);
    LOG_IF_DIFFERENT(boxReflect);

    LOG_IF_DIFFERENT(pageSize);

    LOG_IF_DIFFERENT(shapeOutside);
    LOG_IF_DIFFERENT(shapeMargin);
    LOG_IF_DIFFERENT(shapeImageThreshold);

    LOG_IF_DIFFERENT(perspective);
    LOG_IF_DIFFERENT(perspectiveOrigin);

    LOG_IF_DIFFERENT(clipPath);

    LOG_IF_DIFFERENT(textDecorationColor);

    customProperties->dumpDifferences(ts, other.customProperties);
    LOG_IF_DIFFERENT(customPaintWatchedProperties);

    LOG_IF_DIFFERENT(rotate);
    LOG_IF_DIFFERENT(scale);
    LOG_IF_DIFFERENT(translate);

    LOG_IF_DIFFERENT(containerNames);

    LOG_IF_DIFFERENT(viewTransitionClasses);
    LOG_IF_DIFFERENT(viewTransitionName);

    LOG_IF_DIFFERENT(columnGap);
    LOG_IF_DIFFERENT(rowGap);
    LOG_IF_DIFFERENT(itemTolerance);

    LOG_IF_DIFFERENT(offsetPath);
    LOG_IF_DIFFERENT(offsetDistance);
    LOG_IF_DIFFERENT(offsetPosition);
    LOG_IF_DIFFERENT(offsetAnchor);
    LOG_IF_DIFFERENT(offsetRotate);

    LOG_IF_DIFFERENT(textDecorationThickness);

    LOG_IF_DIFFERENT(scrollTimelines);
    LOG_IF_DIFFERENT(scrollTimelineAxes);
    LOG_IF_DIFFERENT(scrollTimelineNames);

    LOG_IF_DIFFERENT(viewTimelines);
    LOG_IF_DIFFERENT(viewTimelineInsets);
    LOG_IF_DIFFERENT(viewTimelineAxes);
    LOG_IF_DIFFERENT(viewTimelineNames);

    LOG_IF_DIFFERENT(timelineScope);

    LOG_IF_DIFFERENT(scrollbarGutter);

    LOG_IF_DIFFERENT(scrollSnapType);
    LOG_IF_DIFFERENT(scrollSnapAlign);

    LOG_IF_DIFFERENT(pseudoElementNameArgument);

    LOG_IF_DIFFERENT(anchorNames);
    LOG_IF_DIFFERENT(anchorScope);
    LOG_IF_DIFFERENT(positionAnchor);
    LOG_IF_DIFFERENT(positionArea);
    LOG_IF_DIFFERENT(positionTryFallbacks);
    LOG_IF_DIFFERENT(usedPositionOptionIndex);
    LOG_IF_DIFFERENT(positionVisibility);

    LOG_IF_DIFFERENT(blockStepSize);

    LOG_IF_DIFFERENT_WITH_CAST(BlockStepAlign, blockStepAlign);
    LOG_IF_DIFFERENT_WITH_CAST(BlockStepInsert, blockStepInsert);
    LOG_IF_DIFFERENT_WITH_CAST(BlockStepRound, blockStepRound);

    LOG_IF_DIFFERENT_WITH_CAST(OverscrollBehavior, overscrollBehaviorX);
    LOG_IF_DIFFERENT_WITH_CAST(OverscrollBehavior, overscrollBehaviorY);

    LOG_IF_DIFFERENT_WITH_CAST(TransformStyle3D, transformStyle3D);
    LOG_IF_DIFFERENT_WITH_CAST(bool, transformStyleForcedToFlat);
    LOG_IF_DIFFERENT_WITH_CAST(BackfaceVisibility, backfaceVisibility);

    LOG_IF_DIFFERENT_WITH_CAST(Style::ScrollBehavior, scrollBehavior);
    LOG_IF_DIFFERENT_WITH_CAST(TextDecorationStyle, textDecorationStyle);
    LOG_IF_DIFFERENT_WITH_CAST(TextGroupAlign, textGroupAlign);

    LOG_IF_DIFFERENT_WITH_CAST(ContentVisibility, contentVisibility);
    LOG_IF_DIFFERENT_WITH_CAST(BlendMode, effectiveBlendMode);

    LOG_IF_DIFFERENT_WITH_CAST(Isolation, isolation);

    LOG_IF_DIFFERENT_WITH_CAST(InputSecurity, inputSecurity);

#if ENABLE(APPLE_PAY)
    LOG_IF_DIFFERENT_WITH_CAST(ApplePayButtonStyle, applePayButtonStyle);
    LOG_IF_DIFFERENT_WITH_CAST(ApplePayButtonType, applePayButtonType);
#endif

    LOG_IF_DIFFERENT_WITH_CAST(BreakBetween, breakBefore);
    LOG_IF_DIFFERENT_WITH_CAST(BreakBetween, breakAfter);
    LOG_IF_DIFFERENT_WITH_CAST(BreakInside, breakInside);

    LOG_IF_DIFFERENT_WITH_CAST(ContainerType, containerType);
    LOG_IF_DIFFERENT_WITH_CAST(TextBoxTrim, textBoxTrim);
    LOG_IF_DIFFERENT_WITH_CAST(OverflowAnchor, overflowAnchor);
    LOG_IF_DIFFERENT_WITH_CAST(Style::PositionTryOrder, positionTryOrder);
    LOG_IF_DIFFERENT_WITH_CAST(FieldSizing, fieldSizing);

    LOG_IF_DIFFERENT_WITH_CAST(bool, nativeAppearanceDisabled);

#if HAVE(CORE_MATERIAL)
    LOG_IF_DIFFERENT_WITH_CAST(AppleVisualEffect, appleVisualEffect);
#endif

    LOG_IF_DIFFERENT_WITH_CAST(Style::ScrollbarWidth, scrollbarWidth);

    LOG_IF_DIFFERENT_WITH_CAST(bool, usesAnchorFunctions);
    LOG_IF_DIFFERENT_WITH_CAST(bool, anchorFunctionScrollCompensatedAxes);
    LOG_IF_DIFFERENT_WITH_CAST(bool, isPopoverInvoker);
    LOG_IF_DIFFERENT_WITH_CAST(bool, useSVGZoomRulesForLength);

    LOG_IF_DIFFERENT_WITH_FROM_RAW(Style::MarginTrim, marginTrim);
    LOG_IF_DIFFERENT_WITH_FROM_RAW(Style::Contain, contain);

    LOG_IF_DIFFERENT_WITH_CAST(OverflowContinue, overflowContinue);
    LOG_IF_DIFFERENT_WITH_CAST(ScrollSnapStop, scrollSnapStop);
}
#endif // !LOG_DISABLED

} // namespace WebCore
