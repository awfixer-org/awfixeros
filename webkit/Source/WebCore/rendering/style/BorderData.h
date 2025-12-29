/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
 * Copyright (C) 2006 Graham Dennis (graham.dennis@gmail.com)
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

#pragma once

#include <WebCore/BorderValue.h>
#include <WebCore/RectCorners.h>
#include <WebCore/RectEdges.h>
#include <WebCore/StyleBorderImageData.h>
#include <WebCore/StyleBorderRadius.h>
#include <WebCore/StyleCornerShapeValue.h>
#include <wtf/DataRef.h>

namespace WebCore {

using namespace CSS::Literals;

struct BorderData {
    using Radii = Style::BorderRadius;

    BorderData();

    bool hasBorder() const
    {
        return edges.anyOf([](const auto& edge) { return edge.nonZero(); });
    }

    bool hasVisibleBorder() const
    {
        return edges.anyOf([](const auto& edge) { return edge.isVisible(); });
    }

    bool hasBorderImage() const
    {
        return !borderImage->borderImage.borderImageSource.isNone();
    }

    bool hasBorderRadius() const
    {
        return radii.anyOf([](auto& corner) { return !Style::isKnownEmpty(corner); });
    }

    template<BoxSide side>
    Style::LineWidth borderEdgeWidth() const
    {
        if (!edges[side].hasVisibleStyle())
            return 0_css_px;
        if (borderImage->borderImage.borderImageWidth.overridesBorderWidths()) {
            if (auto fixedBorderWidthValue = borderImage->borderImage.borderImageWidth.values[side].tryFixed())
                return Style::LineWidth { fixedBorderWidthValue->unresolvedValue() };
        }
        return edges[side].width;
    }

    Style::LineWidth borderLeftWidth() const { return borderEdgeWidth<BoxSide::Left>(); }
    Style::LineWidth borderRightWidth() const { return borderEdgeWidth<BoxSide::Right>(); }
    Style::LineWidth borderTopWidth() const { return borderEdgeWidth<BoxSide::Top>(); }
    Style::LineWidth borderBottomWidth() const { return borderEdgeWidth<BoxSide::Bottom>(); }

    Style::LineWidthBox borderWidth() const
    {
        return { borderTopWidth(), borderRightWidth(), borderBottomWidth(), borderLeftWidth() };
    }

    // `BorderEdgesView` provides a RectEdges-like interface for efficiently working with
    // the values stored in BorderValue by edge. This allows `RenderStyle` code generation
    // to work as if the `border-{edge}-*`properties were stored in a RectEdges, while
    // instead storing them grouped together by edge in BorderValue.
    //
    // FIXME: Currently this is only implemented for `border-{edge}-color` and `border-{edge}-style`,
    // due to `border-{edge}-width` needing to return the computed value from borderEdgeWidth() from
    // its getter.
    template<bool isConst, template<BoxSide> typename Accessor, typename GetterType, typename SetterType = GetterType>
    struct BorderEdgesView {
        GetterType top() const { return Accessor<BoxSide::Top>::get(borderData); }
        GetterType right() const { return Accessor<BoxSide::Right>::get(borderData); }
        GetterType bottom() const { return Accessor<BoxSide::Bottom>::get(borderData); }
        GetterType left() const { return Accessor<BoxSide::Left>::get(borderData); }

        void setTop(SetterType value) requires (!isConst) { Accessor<BoxSide::Top>::set(borderData, std::forward<SetterType>(value)); }
        void setRight(SetterType value) requires (!isConst){ Accessor<BoxSide::Right>::set(borderData, std::forward<SetterType>(value)); }
        void setBottom(SetterType value) requires (!isConst){ Accessor<BoxSide::Bottom>::set(borderData, std::forward<SetterType>(value)); }
        void setLeft(SetterType value) requires (!isConst) { Accessor<BoxSide::Left>::set(borderData, std::forward<SetterType>(value)); }

        std::conditional_t<isConst, const BorderData&, BorderData&> borderData;
    };

    template<BoxSide side> struct ColorAccessor {
        static const Style::Color& get(const BorderData& data) { return data.edges[side].color; }
        static void set(BorderData& data, Style::Color&& color) { data.edges[side].color = WTF::move(color); }
    };
    using BorderColorsView = BorderEdgesView<false, ColorAccessor, const Style::Color&, Style::Color&&>;
    using BorderColorsConstView = BorderEdgesView<true, ColorAccessor, const Style::Color&, Style::Color&&>;
    BorderColorsView colors() { return { .borderData = *this }; }
    BorderColorsConstView colors() const { return { .borderData = *this }; }

    template<BoxSide side> struct StyleAccessor {
        static unsigned get(const BorderData& data) { return data.edges[side].style; }
        static void set(BorderData& data, unsigned style) { data.edges[side].style = style; }
    };
    using BorderStylesView = BorderEdgesView<false, StyleAccessor, unsigned>;
    using BorderStylesConstView = BorderEdgesView<true, StyleAccessor, unsigned>;
    BorderStylesView styles() { return { .borderData = *this }; }
    BorderStylesConstView styles() const { return { .borderData = *this }; }

    BorderValue& left() { return edges.left(); }
    BorderValue& right() { return edges.right(); }
    BorderValue& top() { return edges.top(); }
    BorderValue& bottom() { return edges.bottom(); }

    const BorderValue& left() const { return edges.left(); }
    const BorderValue& right() const { return edges.right(); }
    const BorderValue& top() const { return edges.top(); }
    const BorderValue& bottom() const { return edges.bottom(); }

    Style::BorderRadiusValue& topLeftRadius() { return radii.topLeft(); }
    Style::BorderRadiusValue& topRightRadius() { return radii.topRight(); }
    Style::BorderRadiusValue& bottomLeftRadius() { return radii.bottomLeft(); }
    Style::BorderRadiusValue& bottomRightRadius() { return radii.bottomRight(); }

    const Style::BorderRadiusValue& topLeftRadius() const { return radii.topLeft(); }
    const Style::BorderRadiusValue& topRightRadius() const { return radii.topRight(); }
    const Style::BorderRadiusValue& bottomLeftRadius() const { return radii.bottomLeft(); }
    const Style::BorderRadiusValue& bottomRightRadius() const { return radii.bottomRight(); }

    const Style::CornerShapeValue& topLeftCornerShape() const { return cornerShapes.topLeft(); }
    const Style::CornerShapeValue& topRightCornerShape() const { return cornerShapes.topRight(); }
    const Style::CornerShapeValue& bottomLeftCornerShape() const { return cornerShapes.bottomLeft(); }
    const Style::CornerShapeValue& bottomRightCornerShape() const { return cornerShapes.bottomRight(); }

    bool containsCurrentColor() const;

    bool operator==(const BorderData&) const = default;

    void dump(TextStream&, DumpStyleValues = DumpStyleValues::All) const;
#if !LOG_DISABLED
    void dumpDifferences(TextStream&, const BorderData&) const;
#endif

    RectEdges<BorderValue> edges;
    Style::BorderRadius radii { Style::BorderRadiusValue { 0_css_px, 0_css_px } };
    Style::CornerShape cornerShapes { Style::CornerShapeValue(CSS::Keyword::Round { }) };
    DataRef<StyleBorderImageData> borderImage;
};

WTF::TextStream& operator<<(WTF::TextStream&, const BorderData&);

} // namespace WebCore
