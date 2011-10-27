require("rubygems")
require("sha1")
require: "sinatra"
require: "html"
require: "redis"

R = Redis Client new

configure: { enable: 'sessions }
configure: 'production with: { disable: 'show_errors }
configure: ['production, 'development] with: {
  enable: 'logging
}

set: 'port to: 3000

# basic layout
def with_layout: body {
  HTML new: |h| {
    h html: {
      h head: {
        h title: "Shortefy v0.0.1"
      }
      h body: {
        body(h)
      }
    }
  } to_s
}

def with_link: id do: block else: else_block ({ "" }) {
  if: (R[('get, key: id)]) then: |link| {
    block(link)
  } else: else_block
}

def key: id {
  "shortefy:#{id}"
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
  R[('set, key: key, link)]
  redirect: "/show/#{key}"
}

get: "/show/:id" do: |id| {
  with_link: id do: |link| {
    with_layout: |h| {
      h h1: "ID: #{id}"
      h h2: {
        h a: <['href => link]> with: link
      }
    }
  } else: {
    redirect: "/"
  }
}

get: "/:id" do: |id| {
  with_link: id do: |link| {
    redirect: link
  }
}

not_found: { "Invalid page. Sorry :(" }
