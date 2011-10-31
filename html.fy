# html_generator.fy
# Simple HTML generator written in fancy

class String {
  def but_last {
    # same as:  self from: 0 to: -2
    # and:      self from: 0 to: (self size - 2)
    self[[0,-2]]
  }
}

class HTML {
  def initialize {
    @buf = ""
    @indent = 0
  }

  def initialize: block {
    initialize
    block call: [self]
  }

  def open_tag: name attrs: attrs (<[]>) indent: indent (true) {
    @buf << "\n"
    @buf << (" " * @indent)
    @indent = @indent + 2

    @buf << "<" << (name but_last)
    unless: (attrs empty?) do: {
      @buf << " "
      attrs each: |k v| {
        @buf << k << "=" << (v inspect)
      } in_between: {
        @buf << " "
      }
    }
    @buf << ">"

    { @indent = @indent - 2 } unless: indent
  }

  def close_tag: name {
    @buf << "\n"
    @indent = @indent - 2
    @buf << (" " * @indent)

    @buf << "</" << (name but_last) << ">"
  }

  def html_block: tag body: body attrs: attrs (<[]>) {
    open_tag: tag attrs: attrs
    match body first {
      case Block -> @buf << (body first call)
      case _ -> @buf << "\n" << (" " * @indent) << (body first)
    }
    close_tag: tag
    nil
  }

  def unknown_message: m with_params: p {
    match m to_s {
      case /with:$/ ->
        tag = m to_s substitute: /with:$/ with: ""
        html_block: tag body: (p rest) attrs: (p first to_hash)
      case _ ->
        html_block: (m to_s) body: p
    }
    nil
  }

  def br {
    @buf << "\n" << (" " * @indent)
    @buf << "<br/>"
    nil
  }

  def input: attrs {
    open_tag: "input:" attrs: (attrs to_hash) indent: false
    nil
  }

  def to_s {
    @buf from: 1 to: -1
  }
}