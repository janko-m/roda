require File.expand_path("spec_helper", File.dirname(File.dirname(__FILE__)))

begin
  require 'erubis'
  require 'tilt/erb'
  begin
    require 'tilt/erubis'
  rescue LoadError
    # Tilt 1 support
  end
rescue LoadError
  warn "tilt or erubis not installed, skipping _erubis_escaping plugin test"  
else
describe "_erubis_escaping plugin" do
  it "should escape inside <%= %> and not inside <%== %>, and handle postfix conditionals" do
    app(:bare) do
      plugin :render, :escape=>true

      route do |r|
        render(:inline=>'<%= "<>" %> <%== "<>" %><%= "<>" if false %>')
      end
    end

    body.should == '&lt;&gt; <>'
  end

  it "should consider classes in :escape_safe_classes as safe" do
    c = Class.new(String)
    c2 = Class.new(String)
    app(:bare) do
      plugin :render, :escape=>true, :escape_safe_classes=>c

      route do |r|
        @c, @c2 = c, c2
        render(:inline=>'<%= @c2.new("<>") %> <%= @c.new("<>") %>')
      end
    end

    body.should == '&lt;&gt; <>'
  end

  it "should allow use of custom :escaper" do
    escaper = Object.new
    def escaper.escape_xml(s)
      s.gsub("'", "''")
    end
    app(:bare) do
      plugin :render, :escape=>true, :escaper=>escaper

      route do |r|
        render(:inline=>'<%= "ab\'1" %> <%== "ab\'1" %>')
      end
    end

    body.should == "ab''1 ab'1"
  end
end
end
