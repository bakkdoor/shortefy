require("rubygems")
require("sha1")
require: "sinatra"
require: "../lib/html"

LINKS = <[]>

configure: { enable: 'sessions }
configure: 'production with: { disable: 'show_errors }
configure: ['production, 'development] with: {
  enable: 'logging
}

set: 'port to: 3000

# basic layout
def with_layout: b {
  HTML new: |h| {
    h html: {
      h head: {
        h title: "Shortefy v0.0.1"
      }
      h body: {
        b call: [h]
      }
    }
  } to_s
}

get: "/" do: {
  with_layout: |h| {
    h form: <['action => "/new", 'method => "post"]> with: {
      h fieldset: {
        h label: <['for => "title"]> with: "Link"
        h br
        h input: <['type => "text", 'id => "link", 'name => "link", 'value => "http://"]>
        h br
        h input: <['type => "submit", 'value => "SAVE"]>
      }
    }
  }
}

post: "/new" do: {
  link = params['link]
  key = SHA1 new(link) to_s [[0, 10]]
  LINKS[key]: link
  redirect: "/show/#{key}"
}

get: /^\/show/([a-zA-Z0-9]+)/ do: |id| {
  if: (get_link: id) then: |link| {
    with_layout: |h| {
      h h1: "ID: #{id}"
      h h2: {
        h a: <['href => link]> with: link
      }
    }
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
