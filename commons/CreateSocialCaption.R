# A common function to to modify author details as needed
# Credits: https://www.r-bloggers.com/2023/07/adding-social-media-icons-to-charts-with-ggplot2/ and
# https://albert-rapp.de/posts/ggplot2-tips/08_fonts_and_icons/08_fonts_and_icons

library(glue)

CreateSocialCaption <- function(
    github_user = "emaleckova",
    linkedin_user = "evamaleckova",
    github_icon_color = "#000000",
    linkedin_icon_color = "#0077B5",
    text_color = "#000000",
    font_family = "fa-brands"
) {
  # Icon unicode constants
  github_icon <- "&#xf09b;"
  linkedin_icon <- "&#xf08c;"
  
  glue::glue(
    "<span style='font-family:\"{font_family}\"; color:{github_icon_color}'>{github_icon}</span>
     <span style='color:{text_color}'>{github_user}</span>
     <span style='font-family:\"{font_family}\"; color:{linkedin_icon_color}'>{linkedin_icon}</span>
     <span style='color:{text_color}'>{linkedin_user}</span>"
  )
}

# Handle brands font
sysfonts::font_add(
  family = "fa-brands", 
  regular = "commons/fonts/Font Awesome 7 Brands-Regular-400.otf"
)

# enable showtext
showtext::showtext_auto()
