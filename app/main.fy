require("rubygems")
require("sha1")
require: "sinatra"
require: "../lib/template"

WIKI_ROOT = File expand_path(".", File dirname(__FILE__))
Template path_prefix: WIKI_ROOT

LINKS = <[]>

configure: { enable: 'sessions }
configure: 'production with: { disable: 'show_errors }
configure: ['production, 'development] with: {
  enable: 'logging
}
configure: 'development with: {
  Template caching: false # disable caching in dev mode
}
set: 'port to: 3000

get: "/" do: {
  Template["views/index.fyhtml"] render
}

post: "/new" do: {
  link = params['link]
  key = SHA1 new(link) to_s [[0, 10]]
  LINKS[key]: link
  redirect: "/show/#{key}"
}

get: /^\/show/([a-zA-Z0-9]+)/ do: |id| {
  if: (get_link: id) then: |link| {
    Template["views/show.fyhtml"] render: <['id => id, 'link => link]>
  }
}

get: /^\/([a-zA-Z0-9]+)/ do: |id| {
  redirect: $ get_link: id
}

def get_link: id {
  if: (LINKS[id]) then: |link| {
    link
  } else: {
    "Link '#{id}' does not exist!" raise!
  }
}

not_found: { "Invalid page. Sorry :(" }
