// Copyright 2023 RisingWave Labs
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use risingwave_common::types::F64;
use risingwave_expr_macro::function;

#[function("sin(float64) -> float64")]
pub fn sin_f64(input: F64) -> F64 {
    f64::sin(input.0).into()
}

#[function("cos(float64) -> float64")]
pub fn cos_f64(input: F64) -> F64 {
    f64::cos(input.0).into()
}

#[function("tan(float64) -> float64")]
pub fn tan_f64(input: F64) -> F64 {
    f64::tan(input.0).into()
}

#[function("cot(float64) -> float64")]
pub fn cot_f64(input: F64) -> F64 {
    let res = 1.0 / f64::tan(input.0);
    res.into()
}

#[function("asin(float64) -> float64")]
pub fn asin_f64(input: F64) -> F64 {
    f64::asin(input.0).into()
}

#[function("acos(float64) -> float64")]
pub fn acos_f64(input: F64) -> F64 {
    f64::acos(input.0).into()
}

#[function("atan(float64) -> float64")]
pub fn atan_f64(input: F64) -> F64 {
    f64::atan(input.0).into()
}

#[function("atan2(float64, float64) -> float64")]
pub fn atan2_f64(input_x: F64, input_y: F64) -> F64 {
    input_x.0.atan2(input_y.0).into()
}

#[function("sind(float64) -> float64")]
pub fn sind_f64(input: F64) -> F64 {
    f64::sin(f64::to_radians(input.0)).into()
}

#[function("cosd(float64) -> float64")]
pub fn cosd_f64(input: F64) -> F64 {
    f64::cos(f64::to_radians(input.0)).into()
}

#[function("tand(float64) -> float64")]
pub fn tand_f64(input: F64) -> F64 {
    f64::tan(f64::to_radians(input.0)).into()
}

#[function("cotd(float64) -> float64")]
pub fn cotd_f64(input: F64) -> F64 {
    let res = 1.0 / f64::tan(f64::to_radians(input.0));
    res.into()
}

#[function("asind(float64) -> float64")]
pub fn asind_f64(input: F64) -> F64 {
    f64::asin(f64::to_radians(input.0)).into()
}

#[function("acosd(float64) -> float64")]
pub fn acosd_f64(input: F64) -> F64 {
    f64::acos(f64::to_radians(input.0)).into()
}

#[function("atand(float64) -> float64")]
pub fn atand_f64(input: F64) -> F64 {
    f64::atan(f64::to_radians(input.0)).into()
}

#[function("atan2d(float64, float64) -> float64")]
pub fn atan2d_f64(input_x: F64, input_y: F64) -> F64 {
    f64::to_radians(input_x.0)
        .atan2(f64::to_radians(input_y.0))
        .into()
}

#[cfg(test)]
mod tests {

    use std::f64::consts::PI;

    use num_traits::ToPrimitive;
    use risingwave_common::types::F64;

    use crate::vector_op::trigonometric::*;

    /// numbers are equal within a rounding error
    fn assert_similar(lhs: F64, rhs: F64) {
        let x = F64::from(lhs.abs() - rhs.abs()).abs() <= 0.000000000000001;
        assert!(x);
    }

    #[test]
    fn test_degrees() {
        let d = F64::from(180);
        let d2 = F64::from(90);
        let pi = F64::from(PI);
        let pi2 = F64::from(PI / 2.to_f64().unwrap());
        assert_eq!(sin_f64(pi), sind_f64(d));
        assert_eq!(cos_f64(pi), cosd_f64(d));
        assert_eq!(tan_f64(pi), tand_f64(d));
        assert_eq!(cot_f64(pi), cotd_f64(d));
        assert_eq!(asin_f64(pi), asind_f64(d));
        assert_eq!(acos_f64(pi), acosd_f64(d));
        assert_eq!(atan_f64(pi), atand_f64(d));
        assert_eq!(atan2_f64(pi, pi2), atan2d_f64(d, d2));
    }

    #[test]
    fn test_trigonometric_funcs() {
        // from https://en.wikipedia.org/wiki/Trigonometric_functions#Sum_and_difference_formulas
        let x = F64::from(1);
        let y = F64::from(3);
        let one = F64::from(1);
        assert_similar(
            sin_f64(x + y),
            sin_f64(x) * cos_f64(y) + cos_f64(x) * sin_f64(y),
        );
        assert_similar(
            cos_f64(x + y),
            cos_f64(x) * cos_f64(y) - sin_f64(x) * sin_f64(y),
        );
        assert_similar(
            tan_f64(x + y),
            (tan_f64(x) + tan_f64(y)) / (one - tan_f64(x) * tan_f64(y)),
        );
    }

    #[test]
    fn test_inverse_trigonometric_funcs() {
        let x = F64::from(1);
        let y = F64::from(3);
        let two = F64::from(2);
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Relationships_between_trigonometric_functions_and_inverse_trigonometric_functions
        assert_similar(x, sin_f64(asin_f64(x)));
        assert_similar(x, cos_f64(acos_f64(x)));
        assert_similar(x, tan_f64(atan_f64(x)));
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent
        assert_similar(
            atan2_f64(y, x),
            two * atan_f64(y / (F64::from(F64::from(x.powi(2) + y.powi(2)).sqrt()) + x)),
        )
    }
}