#' Dowloads sno-tel data based upon a subset of the
#' sno-tel info as provided by snotel.info()
#'
#' @param sites: subset of the sites listed by snotel.info()
#' @param path: where to save downloaded files
#' @keywords SNOTEL, USDA, sites, locations, web scraping
#' @export
#' @examples
#'
#' # would download all available snotel data
#' # df = snotel.download(sites = snotel.info())

download.snotel = function(sites = NULL, path = "."){

  # check if there is a meta-data file in the current
  # working directory
  if (!file.exists("snotel_metadata.csv")) {
    print("no metadata cached, downloading metadata")
    meta_data = snotel.info()
  } else {
    meta_data = utils::read.csv("snotel_metadata.csv", header = TRUE, sep = ",")
  }

  # trap empty sites parameter, if all, downloadd all data
  # if string of IDs subset the dataset.
  if (is.null(sites)){
    stop("no sites specified")
  } else {
    if (sites != "all" | sites != "ALL"){
      meta_data = meta_data[which(meta_data$site_id %in% sites),]
    }
  }

  # loop over selection, and download the data
  for (i in 1:nrow(meta_data)){

    # some feedback
    cat(sprintf("processing site: %s, with id: %s\n",meta_data$site_name[i],meta_data$site_id[i]))

    # download url
    base_url = paste("https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport,metric/daily/",
                     meta_data$site_id[i],":",meta_data$state[i],":",meta_data$network[i],
                     "%7Cid=%22%22%7Cname/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,TMIN::value,TAVG::value,PRCP::value",sep="")

    # filename
    filename = sprintf("%s/%s_%s.csv",path,"snotel",meta_data$site_id[i])

    # download the data
    curl::curl_download(base_url,destfile = filename)

  }
}
