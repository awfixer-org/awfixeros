/*
 * Copyright (C) 2025 Samuel Weinig <sam@webkit.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include "StyleComputedStyle+GettersInlines.h"
#include "WebAnimationTypes.h"

namespace WebCore {
namespace Style {

class ChangedAnimatablePropertiesCustom final {
public:
    static void conservativelyCollectChangedAnimatablePropertiesForCursor(const ComputedStyle::InheritedFlags&, const ComputedStyle::InheritedFlags&, CSSPropertiesBitSet&);
    static void conservativelyCollectChangedAnimatablePropertiesForZIndex(const StyleBoxData&, const StyleBoxData&, CSSPropertiesBitSet&);
    static void conservativelyCollectChangedAnimatablePropertiesForCaretColor(const StyleRareInheritedData&, const StyleRareInheritedData&, CSSPropertiesBitSet&);
};

inline void ChangedAnimatablePropertiesCustom::conservativelyCollectChangedAnimatablePropertiesForCursor(const ComputedStyle::InheritedFlags& a, const ComputedStyle::InheritedFlags& b, CSSPropertiesBitSet& changingProperties)
{
    if (a.cursorType != b.cursorType)
        changingProperties.m_properties.set(CSSPropertyCursor);
}

inline void ChangedAnimatablePropertiesCustom::conservativelyCollectChangedAnimatablePropertiesForZIndex(const StyleBoxData& a, const StyleBoxData& b, CSSPropertiesBitSet& changingProperties)
{
    if (a.specifiedZIndex() != b.specifiedZIndex())
        changingProperties.m_properties.set(CSSPropertyZIndex);
}

inline void ChangedAnimatablePropertiesCustom::conservativelyCollectChangedAnimatablePropertiesForCaretColor(const StyleRareInheritedData& a, const StyleRareInheritedData& b, CSSPropertiesBitSet& changingProperties)
{
    if (a.caretColor != b.caretColor || a.visitedLinkCaretColor != b.visitedLinkCaretColor || a.hasAutoCaretColor != b.hasAutoCaretColor || a.hasVisitedLinkAutoCaretColor != b.hasVisitedLinkAutoCaretColor)
        changingProperties.m_properties.set(CSSPropertyCaretColor);
}

} // namespace Style
} // namespace WebCore
