# Original project polygons, preserved unchanged. Source verification is pending.

data <- data.frame (Clay=c(0, 0, 0.09, 0.08,
                                      0.12, 0.1, 0.2, 0.32,
                                      0.75, 0.4, 0.4,
                                      0.08, 0.18, 0.2, 0.1,
                                      0.28, 0.5, 0.32,
                                      1, 0.5, 0.32, 0.4, 0.75,
                                      0.4, 0.4, 0.32, 0.32,
                                      0.32, 0.32, 0, 0,
                                      0.09, 0, 0, 0.12,
                                      0.18, 0.2, 0.32, 0.28,
                                      0.4, 0.32, 0.2, 0.32),


                               Sand=c(1, 0.93, 0.85, 0.92,
                                      0.63, 0.765, 0.7, 0.43,
                                      0, 0.35, 0,
                                      0.92, 0.82, 0.7, 0.765,
                                      0.72, 0.5, 0.62,
                                      0, 0.5, 0.62, 0.35, 0,
                                      0.35, 0, 0, 0.43,
                                      0.43, 0, 0, 0.75,
                                      0.85, 0.93, 0.75, 0.63,
                                      0.82, 0.7, 0.62, 0.72,
                                      0.35, 0.43, 0.7, 0.62),

                               Silt=c(0, 0.07, 0.06, 0,
                                      0.25, 0.135, 0.1, 0.25,
                                      0.25, 0.25, 0.6,
                                      0, 0, 0.1, 0.135,
                                      0, 0, 0.06,
                                      0, 0, 0.06, 0.25, 0.25,
                                      0.25, 0.6, 0.68, 0.25,
                                      0.25, 0.68, 1, 0.25,
                                      0.06, 0.07, 0.25, 0.25,
                                      0, 0.1, 0.06, 0,
                                      0.25, 0.25, 0.1, 0.06),

                               Label=c("Sand","Sand","Sand", "Sand",
                                       "Loam", "Loam", "Loam", "Loam",
                                       "Silty Clay", "Silty Clay", "Silty Clay",
                                       "Sandy Loam", "Sandy Loam", "Sandy Loam", "Sandy Loam",
                                       "Sandy Clay", "Sandy Clay", "Sandy Clay",
                                       "Clay", "Clay", "Clay", "Clay", "Clay",
                                       "Silty Clay Loam", "Silty Clay Loam", "Silty Clay Loam", "Silty Clay Loam",
                                       "Silty Loam", "Silty Loam", "Silty Loam", "Silty Loam",
                                       "Loamy Sand", "Loamy Sand", "Loamy Sand", "Loamy Sand",
                                       "Sandy Clay Loam", "Sandy Clay Loam", "Sandy Clay Loam", "Sandy Clay Loam",
                                       "Clay Loam", "Clay Loam", "Clay Loam", "Clay Loam")
)


definition <- list(id = "Australian", display = "Australian", order = 30, clockwise = TRUE,
    colours = c(Sand = "#efe4c7", Loam = "#dedab9", `Silty Clay` = "#c7cbd9",
    `Sandy Loam` = "#e8d7b7", `Sandy Clay` = "#d3b49d", Clay = "#d8c8b1",
    `Silty Clay Loam` = "#c6d1bd", `Silty Loam` = "#cadcd4",
    `Loamy Sand` = "#dfd1a7", `Sandy Clay Loam` = "#e0c9a6",
    `Clay Loam` = "#d4c8a0"), label_size = 3.5, label_overrides = list(
        `Sandy Clay` = list(angle = 60), `Sandy Loam` = list(
            angle = 60), `Sandy Clay Loam` = list(angle = 60,
            size = 2.5), `Clay Loam` = list(angle = 25)))

definition$data <- data
definition
