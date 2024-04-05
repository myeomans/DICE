utils::globalVariables(c("directModel","diceNGrams","intenseModel","directModel_basic","intenseModel_basic")) # prevent incorrect "no global binding" note

#' DICE Model Scores
#'
#' @description Detects linguistic markers of politeness in natural language.
#'     Takes an N-length vector of text documents and returns an N-row data.frame of scores on the two DICE dimensions.
#' @param text character A vector of texts, each of which will be tallied for DICE features.
#' @param parser character Name of dependency parser to use (see details). Without a dependency parser, some features will be approximated, while others cannot be calculated at all.
#' @param uk_english logical Does the text contain any British English spelling? Including variants (e.g. Canadian). Default is FALSE
#' @param num_mc_cores integer Number of cores for parallelization. Default is 1, but we encourage users to try parallel::detectCores() if possible.
#' @details The best intensity model uses politeness features, which depend on part-of-speech tagged sentences (e.g. "bare commands" are a particular verb class).
#'     To include these features in the analysis, a POS tagger must be initialized beforehand - we currently support SpaCy which must
#'     be installed separately in Python (see example for implementation). If not, a simpler model can be used, though it is somewhat less acruate.
#' @return a data.frame of scores on directness and intensity.
#' @references
#'
#' Weingart et al., 2015
#' Yeomans et al., 2024
#'
#' @examples
#'
#' data("phone_offers")
#'
#' DICE(phone_offers$message, parser="none")
#'
#'\dontrun{
#'
#' # Detect multiple cores automatically for parallel processing
#' DICE(phone_offers$message, num_mc_cores=parallel::detectCores())
#'
#' # Connect to SpaCy installation for part-of-speech features
#' install.packages("spacyr")
#' spacyr::spacy_initialize(python_executable = PYTHON_PATH)
#' DICE(phone_offers$message, parser="spacy")
#'}
#'
#'
#'@export

DICE<-function(text,
               parser=c("none","spacy"),
               uk_english=FALSE,
               num_mc_cores=1){
  if(uk_english){
    text<-usWords(text)
  }

  diceX<-featureSet(text,parser=parser)

  if(parser[1]=="spacy"){
    intense<-stats::predict(intenseModel, newdata = diceX)
    direct<-stats::predict(directModel, newdata = diceX)
  } else{
    intense<-stats::predict(intenseModel_basic, newdata = diceX)
    direct<-stats::predict(directModel_basic, newdata = diceX)
  }



  DICEscores=data.frame(intense,direct)

  return(DICEscores)
}

#diceModel<-readRDS("DICEmodel_basic.RDS")
#
# names(diceModel)
#
# intenseModel_basic<-diceModel$Intense_combo_XG
# directModel_basic<-diceModel$Direct_combo_XG
# save(intenseModel_basic,file="data/intenseModel_basic.rda")
# save(directModel_basic,file="data/directModel_basic.rda")
#
# diceNGrams<-diceModel$xdata$ng
#
# save(diceNGrams,file="data/diceNGrams.rda")