context("Tests for the generateSettings() function")
library(safetyGraphics)
setting_names<-c("id_col","value_col","measure_col","normal_col_low","normal_col_high","studyday_col", "visit_col", "visitn_col", "filters","group_cols", "measure_values", "baseline", "analysisFlag", "x_options", "y_options", "visit_window", "r_ratio_filter", "r_ratio_cut", "showTitle", "warningText", "unit_col", "start_value", "details", "missingValues", "unscheduled_visit_pattern","unscheduled_visits","visits_without_data",'calculate_palt')

test_that("a list with the expected properties and structure is returned for all standards",{
  
  expect_is(generateSettings(standard="None"),"list")
  expect_equal(sort(names(generateSettings(standard="None"))),sort(setting_names))
  expect_equal(sort(names(generateSettings(standard="None")[["measure_values"]])), sort(c("ALT","AST","TB","ALP")))
  
  expect_is(generateSettings(standard="ADaM"),"list")
  expect_equal(sort(names(generateSettings(standard="ADaM"))),sort(setting_names))
  expect_equal(sort(names(generateSettings(standard="ADaM")[["measure_values"]])), sort(c("ALT","AST","TB","ALP")))               
  expect_is(generateSettings(standard="SDTM"),"list")
  expect_equal(sort(names(generateSettings(standard="SDTM"))),sort(setting_names))
  expect_equal(sort(names(generateSettings(standard="SDTM")[["measure_values"]])), sort(c("ALT","AST","TB","ALP")))})

test_that("a warning is thrown if chart isn't found in the chart list",{
  expect_error(generateSettings(chart="aeexplorer"))
  expect_error(generateSettings(chart=""))
  expect_silent(generateSettings(chart="hepExplorer"))
  expect_silent(generateSettings(chart="hepexplorer"))
  expect_silent(generateSettings(chart="HepexploreR"))
})

test_that("data mappings are null when setting=none, character otherwise",{
  data_setting_keys<-c("id_col", "value_col", "measure_col", "normal_col_low", "normal_col_high", "studyday_col","measure_values--ALT","measure_values--ALP","measure_values--TB","measure_values--AST")
  none_settings <- generateSettings(standard="None")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_equal(getSettingValue(settings=none_settings,key=key),NULL)
  }
  
  other_settings <- generateSettings(standard="a different standard") 
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_equal(getSettingValue(settings=other_settings,key=key),NULL)
  }
  
  sdtm_settings <- generateSettings(standard="SDTM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=sdtm_settings,key=key),"character")
  }
  
  
  sdtm_settings2 <- generateSettings(standard="SdTm")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=sdtm_settings2,key=key),"character")
  }
  
  
  adam_settings <- generateSettings(standard="ADaM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=adam_settings,key=key),"character")
  }
  
  adam_settings2 <- generateSettings(standard="ADAM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=adam_settings2,key=key),"character")
  }
  
  
  # Test Partial Spec Match
  partial_adam_settings <- generateSettings(standard="adam", partial=TRUE, partial_keys = c("id_col","measure_col","measure_values--ALT"))
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    if (text_key %in% c("id_col","measure_col","measure_values--ALT")) {
      expect_is(getSettingValue(settings=partial_adam_settings,key=key),"character")
    } else {
      expect_equal(getSettingValue(settings=partial_adam_settings,key=key),NULL)
    }
  }
  
  #Testing that partial cols are only used when partial=TRUE
  full_adam_partial_cols <- generateSettings(standard="ADaM",  partial_keys = c("id_col","measure_col","measure_values--ALT"))
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=full_adam_partial_cols,key=key),"character")
  }
  
  #Testing failure when partial is true with no specified columns
  expect_error(partial_settings_no_cols <- generateSettings(standard="ADaM", partial=TRUE))
  
  #Test useDefaults
  noDefaults <- generateSettings(standard="adam",useDefaults=FALSE)
  option_keys<-c("x_options", "y_options", "visit_window", "r_ratio_filter", "r_ratio_cut", "showTitle", "warningText")
  
  #non data mappings are NA
  for(text_key in option_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_equal(getSettingValue(settings=noDefaults,key=key),NULL)
  }
  
  #data mappings are filled as expected 
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=noDefaults,key=key),"character")
  }
  
  #Test customSettings
  customizations<- tibble(text_key=c("id_col","warningText","measure_values--ALT"),customValue=c("customID","This is a custom warning","custom ALT"))
  customSettings<-generateSettings(standard="adam",custom_settings=customizations)
  expect_equal(getSettingValue(settings=customSettings,key=list("id_col")),"customID")
  expect_equal(getSettingValue(settings=customSettings,key=list("warningText")),"This is a custom warning")
  expect_equal(getSettingValue(settings=customSettings,key=list("measure_values","ALT")),"custom ALT")
  expect_equal(getSettingValue(settings=customSettings,key=list("measure_col")),"PARAM")
})
