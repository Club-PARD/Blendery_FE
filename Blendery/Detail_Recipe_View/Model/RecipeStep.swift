//
//  Recipe.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//
import Foundation

struct RecipeStep: Identifiable {
    let id = UUID()
    let text: String
}

let mockRecipeSteps: [RecipeStep] = [
    RecipeStep(text: "에스프레소 2샷"),
    RecipeStep(text: "초코베이스 2스푼(54g)"),
    RecipeStep(text: "스팀우유 윗선(244g)+혼합"),
    RecipeStep(text: "휘핑크림+코코아파우더 토핑 (1g)")
]
