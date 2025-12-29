/*
 * Copyright (C) 2025 Apple Inc. All rights reserved.
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

#import "config.h"
#import "FECompositeCoreImageApplier.h"

#if USE(CORE_IMAGE)

#import "FEComposite.h"
#import "FilterImage.h"
#import <CoreImage/CoreImage.h>
#import <wtf/TZoneMallocInlines.h>

namespace WebCore {

WTF_MAKE_TZONE_ALLOCATED_IMPL(FECompositeCoreImageApplier);

FECompositeCoreImageApplier::FECompositeCoreImageApplier(const FEComposite& effect)
    : Base(effect)
{
}

bool FECompositeCoreImageApplier::supportsCoreImageRendering(const FEComposite& effect)
{
    return effect.operation() != CompositeOperationType::FECOMPOSITE_OPERATOR_ARITHMETIC;
}

bool FECompositeCoreImageApplier::apply(const Filter&, std::span<const Ref<FilterImage>> inputs, FilterImage& result) const
{
    ASSERT(inputs.size() == 2);
    auto& input1 = inputs[0].get();
    auto& input2 = inputs[1].get();

    auto inputImage1 = input1.ciImage();
    if (!inputImage1)
        return false;

    auto inputImage2 = input2.ciImage();
    if (!inputImage2)
        return false;

    RetainPtr<CIBlendKernel> kernel;
    switch (m_effect->operation()) {
    case CompositeOperationType::FECOMPOSITE_OPERATOR_UNKNOWN:
        return false;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_OVER:
        kernel = [CIBlendKernel sourceOver];
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_IN:
        kernel = [CIBlendKernel sourceIn];
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_OUT:
        kernel = [CIBlendKernel destinationOut];
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_ATOP:
        kernel = [CIBlendKernel sourceAtop];
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_XOR:
        kernel = [CIBlendKernel exclusiveOr];
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_ARITHMETIC:
        ASSERT_NOT_REACHED();
        break;
    case CompositeOperationType::FECOMPOSITE_OPERATOR_LIGHTER:
        kernel = [CIBlendKernel componentAdd];
        break;
    }

    RetainPtr resultImage = [kernel applyWithForeground:inputImage1.get() background:inputImage2.get()];
    result.setCIImage(resultImage.get());
    return true;
}

} // namespace WebCore

#endif // USE(CORE_IMAGE)
