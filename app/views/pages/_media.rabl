object @page

node do |page|

  {
    url: api_space_page_url(page.folder.space, page),
    href: page.href,

    # revisions: {
    #   url:  p.revisions_url,
    #   href: p.revisions_url
    # }
  }
end