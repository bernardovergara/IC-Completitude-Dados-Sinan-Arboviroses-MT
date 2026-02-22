#' Information System to Process Function Mapping
#'
#' This data frame provides an explicit mapping between DataSUS information
#' systems and their corresponding processing functions.
#'
#' @format A data frame with 43 rows and 4 columns:
#' \describe{
#'   \item{information_system}{The information system code (e.g., "SIM-DO")}
#'   \item{process_function}{The name of the corresponding process function}
#'   \item{description}{Description of the information system}
#'   \item{status}{Processing status: "supported" or "not_supported"}
#' }
#'
#' @details
#' This mapping is used internally by the package and can be referenced by users
#' to determine which processing function should be used with which information system.
#'
#' @examples
#' # View the complete mapping
#' system_process_mapping
#'
#' # Find the processing function for a specific system
#' mapping <- system_process_mapping[system_process_mapping$information_system == "SIM-DO", ]
#' print(mapping$process_function)
#'
#' @export
system_process_mapping <- data.frame(
  information_system = c(
    "SIM-DO", "SIM-DOFET", "SIM-DOEXT", "SIM-DOINF", "SIM-DOMAT",
    "SINASC",
    "SIH-RD", "SIH-RJ", "SIH-SP", "SIH-ER",
    "CNES-LT", "CNES-ST", "CNES-DC", "CNES-EQ", "CNES-SR", "CNES-HB", "CNES-PF",
    "CNES-EP", "CNES-RC", "CNES-IN", "CNES-EE", "CNES-EF", "CNES-GM",
    "SIA-AB", "SIA-ABO", "SIA-ACF", "SIA-AD", "SIA-AN", "SIA-AM", "SIA-AQ",
    "SIA-AR", "SIA-ATD", "SIA-PA", "SIA-PS", "SIA-SAD",
    "SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA", "SINAN-MALARIA",
    "SINAN-CHAGAS", "SINAN-LEISHMANIOSE-VISCERAL", "SINAN-LEISHMANIOSE-TEGUMENTAR",
    "SINAN-LEPTOSPIROSE"
  ),
  process_function = c(
    "process_sim", "process_sim", "process_sim", "process_sim", "process_sim",
    "process_sinasc",
    "process_sih", "process_sih", "process_sih", "process_sih",
    "process_cnes", "process_cnes", "process_cnes", "process_cnes", "process_cnes",
    "process_cnes", "process_cnes", "process_cnes", "process_cnes", "process_cnes",
    "process_cnes", "process_cnes", "process_cnes",
    "process_sia", "process_sia", "process_sia", "process_sia", "process_sia",
    "process_sia", "process_sia", "process_sia", "process_sia", "process_sia",
    "process_sia", "process_sia",
    "process_sinan_dengue", "process_sinan_chikungunya", "process_sinan_zika",
    "process_sinan_malaria", "process_sinan_chagas",
    "process_sinan_leishmaniose_visceral", "process_sinan_leishmaniose_tegumentar",
    "process_sinan_leptospirose"
  ),
  description = c(
    "SIM - Mortality (General Deaths)",
    "SIM - Mortality (Fetal Deaths)",
    "SIM - Mortality (External Deaths)",
    "SIM - Mortality (Infant Deaths)",
    "SIM - Mortality (Maternal Deaths)",
    "SINASC - Live Births",
    "SIH - Hospital (General Admissions)",
    "SIH - Hospital (Emergency)",
    "SIH - Hospital (Emergency - SP)",
    "SIH - Hospital (Emergency Reference)",
    "CNES - Health Facilities (Long-term Care)",
    "CNES - Health Facilities (Establishments)",
    "CNES - Health Facilities (Diagnostic)",
    "CNES - Health Facilities (Equipment)",
    "CNES - Health Facilities (Service Registry)",
    "CNES - Health Facilities (Hospital Beds)",
    "CNES - Health Professionals",
    "CNES - Health Facilities (Equipment)",
    "CNES - Health Facilities (Related Resources)",
    "CNES - Health Facilities (Infrastructure)",
    "CNES - Health Facilities (Education)",
    "CNES - Health Facilities (Physical Resources)",
    "CNES - Health Facilities (Management)",
    "SIA - Outpatient (Procedures)",
    "SIA - Outpatient (Oral Health)",
    "SIA - Outpatient (Consolidated)",
    "SIA - Outpatient (Supplementary)",
    "SIA - Outpatient (Analysis)",
    "SIA - Outpatient (Appointments)",
    "SIA - Outpatient (Aquatic Therapy)",
    "SIA - Outpatient (Rehabilitation)",
    "SIA - Outpatient (Teaching)",
    "SIA - Outpatient (Procedures)",
    "SIA - Outpatient (Psychological Services)",
    "SIA - Outpatient (Home Care)",
    "SINAN - Dengue",
    "SINAN - Chikungunya",
    "SINAN - Zika",
    "SINAN - Malaria",
    "SINAN - Chagas Disease",
    "SINAN - Visceral Leishmaniasis",
    "SINAN - Cutaneous Leishmaniasis",
    "SINAN - Leptospirosis"
  ),
  status = c(
    rep("supported", 43)
  ),
  stringsAsFactors = FALSE
)

#' Get Processing Function Name for an Information System
#'
#' Utility function to retrieve the appropriate process function name for a given
#' information system code.
#'
#' @param information_system A character string with the information system code
#'   (e.g., "SIM-DO", "SINAN-DENGUE")
#'
#' @return A character string with the name of the process function, or NA if not found
#'
#' @examples
#' get_process_function("SIM-DO")
#' # Returns: "process_sim"
#'
#' get_process_function("SINAN-DENGUE")
#' # Returns: "process_sinan_dengue"
#'
#' @export
get_process_function <- function(information_system) {
  idx <- match(information_system, system_process_mapping$information_system)
  if (is.na(idx)) {
    warning(
      paste0(
        "Information system '",
        information_system,
        "' not found in mapping"
      )
    )
    return(NA)
  }
  return(system_process_mapping$process_function[idx])
}

#' Process Data by Information System Code
#'
#' This function automatically retrieves and executes the appropriate processing
#' function based on the information system code. It's a convenient wrapper that
#' eliminates the need to remember which process function to use.
#'
#' @param data A data frame containing the data to be processed
#' @param information_system A character string with the information system code
#'   (e.g., "SIM-DO", "SINAN-DENGUE", "SIH-RD")
#' @param ... Additional arguments to pass to the processing function
#'   (e.g., municipality_data = TRUE, information_system = "SIH-RD")
#'
#' @return A processed data frame with labels and formatted variables
#'
#' @details
#' This function automatically finds and calls the correct processing function
#' based on the information system code provided. This is useful when:
#' - You want a unified interface for processing different systems
#' - You're working programmatically and the system type is dynamic
#' - You want to avoid remembering specific function names
#'
#' The function will handle most common arguments, but some system-specific
#' arguments may need to be passed explicitly.
#'
#' @examples
#' \dontrun{
#' # Process SIM data
#' sim_processed <- process_by_system(sim_raw_data, "SIM-DO")
#'
#' # Process SINAN-DENGUE data
#' dengue_processed <- process_by_system(dengue_raw_data, "SINAN-DENGUE")
#'
#' # Process SIH data with custom information_system parameter
#' sih_processed <- process_by_system(
#'   sih_raw_data,
#'   "SIH-RD",
#'   municipality_data = TRUE
#' )
#'
#' # Process CNES with multiple parameters
#' cnes_processed <- process_by_system(
#'   cnes_raw_data,
#'   "CNES-ST",
#'   information_system = "CNES-ST",
#'   nomes = FALSE
#' )
#'
#' # Dynamic processing based on user input
#' system_type <- "SINAN-CHIKUNGUNYA"
#' processed_data <- process_by_system(raw_data, system_type)
#' }
#'
#' @export
process_by_system <- function(data, information_system, ...) {
  # Get the function name
  func_name <- get_process_function(information_system)

  # Check if function was found
  if (is.na(func_name)) {
    stop(
      paste0(
        "No processing function found for system: ",
        information_system
      )
    )
  }

  # Get the function object
  process_func <- get(func_name, mode = "function")

  # Call the function with data and additional arguments
  result <- process_func(data, ...)

  return(result)
}

#' Composition Helper: Get and Call Process Function
#'
#' This function creates a function that can be called directly on data.
#' It's useful for functional programming style or piping.
#'
#' @param information_system A character string with the information system code
#'
#' @return A function that takes data and additional arguments and returns
#'   processed data
#'
#' @details
#' This creates a closure that remembers the information_system and can be
#' called like: `get_processor("SINAN-DENGUE")(data, municipality_data = TRUE)`
#'
#' This is particularly useful in functional programming contexts or with magrittr pipes.
#'
#' @examples
#' \dontrun{
#' # Create a processor function for dengue data
#' dengue_processor <- get_processor("SINAN-DENGUE")
#' processed_dengue <- dengue_processor(raw_dengue_data)
#'
#' # Use with magrittr pipe
#' library(magrittr)
#' processed_data <- raw_data %>%
#'   get_processor("SIM-DO")()
#'
#' # Useful in apply-like functions
#' data_list <- list(data1, data2, data3)
#' processed_list <- lapply(data_list, get_processor("SINAN-DENGUE"))
#' }
#'
#' @export
get_processor <- function(information_system) {
  # Validate information system
  func_name <- get_process_function(information_system)
  if (is.na(func_name)) {
    stop(
      paste0(
        "No processing function found for system: ",
        information_system
      )
    )
  }

  # Get the function object
  process_func <- get(func_name, mode = "function")

  # Return a function that calls process_func
  return(function(data, ...) {
    process_func(data, ...)
  })
}