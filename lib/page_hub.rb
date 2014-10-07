module PageHub
  RESERVED_RESOURCE_TITLES = %w[
    edit settings
  ]

  RESERVED_SPACE_TITLES = %w[
    dashboard
    spaces
    settings
  ]

  RESERVED_USERNAMES = %w[
    pagehub
    names name
    spaces space
    pages page
    users user demo
    organizations organization
    groups group
    spec
    explore search features blog plans interface
    site about open-source faq tos service terms security
    sessions session
    signup
    new
    login logout
    stars favorites
    edu
    help
  ]

  # mapping of displayable font names to actual CSS font-family names
  FONT_MAP = {
    "Proxima Nova" => "ProximaNova-Light",
    "Ubuntu" => "UbuntuRegular",
    "Ubuntu Mono" => "UbuntuMonoRegular",
    "Monospace" => "monospace, Courier New, courier, Mono",
    "Arial" => "Arial",
    "Verdana" => "Verdana",
    "Helvetica Neue" => "Helvetica Neue"
  }
end