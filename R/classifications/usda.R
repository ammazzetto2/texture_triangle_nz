# Original project polygons, preserved unchanged. Source verification is pending.

data <- data.frame (Clay=c(1,0.55,0.4,0.4,0.6,
                                0.55,0.35,0.35,
                                0.35,0.2,0.2,0.275,0.35,
                                0.2,0.15,0,0,0.05,0.05,0.2,
                                0.15,0.1,0,0,
                                0.1,0,0,
                                0.4,0.275,0.275,0.4,
                                0.275,0.2,0.05,0.05,0.275,
                                0.275,0,0,0.125,0.125,0.275,
                                0.6,0.4,0.4,
                                0.4,0.275,0.275,0.4,
                                0.125,0,0,0.125),

                         Sand=c(0,0.45,0.45,0.2,0,
                                0.45,0.65,0.45,
                                0.65,0.8,0.525,0.45,0.45,
                                0.8,0.85,0.7,0.5,0.45,0.525,0.525,
                                0.85,0.9,0.85,0.7,
                                0.9,1,0.85,
                                0.45,0.45,0.2,0.2,
                                0.45,0.525,0.525,0.45,0.225,
                                0.225,0.5,0.2,0.075,0,0,
                                0,0.2,0,
                                0.2,0.2,0,0,
                                0.075,0.2,0,0),

                         Silt=c(0,0,0.15,0.4,0.4,
                                0,0,0.2,
                                0,0,0.275,0.275,0.2,
                                0,0,0.3,0.5,0.5,0.425,0.275,
                                0,0,0.15,0.3,
                                0,0,0.15,
                                0.15,0.275,0.525,0.4,
                                0.275,0.275,0.425,0.5,0.5,
                                0.5,0.5,0.8,0.8,0.875,0.725,
                                0.4,0.4,0.6,
                                0.4,0.525,0.725,0.6,
                                0.8,0.8,1,0.875),

                         Label=c("Clay","Clay","Clay","Clay","Clay",
                                 "Sandy \n Clay","Sandy \n Clay","Sandy \n Clay",
                                 "Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam",
                                 "Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam",
                                 "Loamy Sand", "Loamy Sand","Loamy Sand","Loamy Sand",
                                 "Sand","Sand","Sand",
                                 "Clay Loam","Clay Loam","Clay Loam","Clay Loam",
                                 "Loam","Loam","Loam","Loam","Loam",
                                 "Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam",
                                 "Silty Clay","Silty Clay","Silty Clay",
                                 "Silty Clay \n Loam","Silty Clay \n Loam","Silty Clay \n Loam","Silty Clay \n Loam",
                                 "Silt","Silt","Silt","Silt")
)


definition <- list(id = "USDA", display = "USDA", order = 20, clockwise = TRUE,
    colours = c(Clay = "#d8c8b1", `Sandy Clay` = "#d3b49d", `Sandy Clay Loam` = "#e0c9a6",
    `Sandy Loam` = "#e8d7b7", `Loamy Sand` = "#dfd1a7", Sand = "#efe4c7",
    `Clay Loam` = "#d4c8a0", Loam = "#dedab9", `Silt Loam` = "#cbd5ba",
    `Silty Clay` = "#c7cbd9", `Silty Clay Loam` = "#c6d1bd",
    Silt = "#d8e2d9"), label_size = 4, label_overrides = list(
        `Loamy Sand` = list(angle = 330)))

definition$data <- data
definition
