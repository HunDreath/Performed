//
//  Exercice.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import Foundation

enum Exercice: String, Codable, CaseIterable, Identifiable {
    // PECTORAUX
    case developeCouche = "Développé Couché"
    case developeCoucheIncline = "Développé Couché Incliné"
    case developeCoucheDecline = "Développé Couché Décliné"
    case developeHalteres = "Développé Haltères"
    case developeHalteresIncline = "Développé Haltères Incliné"
    case chestPress = "Chest Press"
    case ecarteCouche = "Écarté Couché"
    case ecarteIncline = "Écarté Incliné"
    case chestPoulieHaute = "Écarté Poulie Haute"
    case chestPoulieBasse = "Écarté Poulie Basse"
    case pullOver = "Pull Over"
    case pompes = "Pompes"
    case dips = "Dips"
    
    // DOS
    case tractionsDos = "Tractions Dos"
    case tractionsSupination = "Tractions Supination"
    case tractionsNeutre = "Tractions Prise Neutre"
    case rowing = "Rowing"
    case rowingBarre = "Rowing Barre"
    case rowingHaltere = "Rowing Haltère"
    case rowingTBarre = "Rowing T-Barre"
    case rowingYates = "Rowing Yates"
    case tirageVertical = "Tirage Vertical"
    case tirageHorizontal = "Tirage Horizontal"
    case tirageNuque = "Tirage Nuque"
    case souleverDeTerre = "Soulevé de Terre"
    case souleveDeTerreRoumain = "Soulevé de Terre Roumain"
    case souleveDeTerreJambesTendues = "Soulevé de Terre Jambes Tendues"
    case souleveDeTerreDeficit = "Soulevé de Terre Déficit"
    case facePull = "Face Pull"
    case shrugs = "Shrugs"
    
    // ÉPAULES
    case developeMilitaire = "Développé Militaire"
    case developeHalteresEpaules = "Développé Haltères Épaules"
    case developeArnold = "Développé Arnold"
    case developeNuque = "Développé Nuque"
    case elevationFrontale = "Élévation Frontale"
    case elevationLaterale = "Élévation Latérale"
    case elevationLateraleIncline = "Élévation Latérale Incliné"
    case rowingVertical = "Rowing Vertical"
    case oiseau = "Oiseau"
    case oiseauPoulie = "Oiseau Poulie"
    
    // BICEPS
    case curlsBiceps = "Curls Biceps"
    case curlsBarre = "Curls Barre"
    case curlsHalteres = "Curls Haltères"
    case curlsMarteau = "Curls Marteau"
    case curlsPupitre = "Curls Pupitre"
    case curlsConcentration = "Curls Concentration"
    case curlsPoulie = "Curls Poulie"
    case curlsIncline = "Curls Incliné"
    
    // TRICEPS
    case extensionsTriceps = "Extensions Triceps"
    case tricepsPoulieHaute = "Triceps Poulie Haute"
    case tricepsPoulieHauteMainSuplination = "Triceps Poulie Haute Main Supination"
    case tricepsPoulieCorde = "Triceps Poulie Corde"
    case barre = "Barre au Front"
    case kickback = "Kickback"
    case dipsTrices = "Dips Triceps"
    case extensionNuque = "Extension Nuque"
    case extensionNuqueHaltere = "Extension Nuque Haltère"
    
    // AVANT-BRAS
    case extensionAvantBrasAssis = "Extension Avant-Bras Assis"
    case curlsPoignets = "Curls Poignets"
    case curlsPoignetsInverse = "Curls Poignets Inversés"
    case farmersWalk = "Farmer's Walk"
    
    // JAMBES - QUADRICEPS
    case squat = "Squat"
    case squatFront = "Squat Front"
    case squatBulgare = "Squat Bulgare"
    case squatSumo = "Squat Sumo"
    case presseCuisses = "Presse Cuisses"
    case hackSquat = "Hack Squat"
    case fentes = "Fentes"
    case fentesAvant = "Fentes Avant"
    case fentesArriere = "Fentes Arrière"
    case fentesLaterales = "Fentes Latérales"
    case legExtension = "Leg Extension"
    case sissy = "Sissy Squat"
    
    // JAMBES - ISCHIO-JAMBIERS
    case legCurl = "Leg Curl"
    case legCurlAllonge = "Leg Curl Allongé"
    case legCurlAssis = "Leg Curl Assis"
    case nordicCurl = "Nordic Curl"
    case goodMorning = "Good Morning"
    
    // JAMBES - FESSIERS
    case hipThrust = "Hip Thrust"
    case kickbackPoulie = "Kickback Poulie"
    case abduction = "Abduction"
    case ponts = "Ponts Fessiers"
    
    // MOLLETS
    case elevationsMollets = "Élévations Mollets"
    case elevationsMolletsDebout = "Élévations Mollets Debout"
    case elevationsMolletsAssis = "Élévations Mollets Assis"
    case elevationsMolletsUnilateral = "Élévations Mollets Unilatéral"
    
    // ABDOMINAUX
    case crunch = "Crunch"
    case crunchObliques = "Crunch Obliques"
    case releveDeBassins = "Relevé de Bassins"
    case planche = "Planche"
    case plancheLaterale = "Planche Latérale"
    case mountainClimbers = "Mountain Climbers"
    case russianTwist = "Russian Twist"
    case roueAbdominale = "Roue Abdominale"
    case leveeDeJambes = "Levée de Jambes"
    case vUps = "V-Ups"
    
    var id: String { self.rawValue }
}
