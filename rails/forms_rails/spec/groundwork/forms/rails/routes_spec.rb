# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Groundwork::Forms::Rails routing helper" do
  class RoutesFlow
    include Groundwork::Forms::Flow

    task :t1 do
      question_page :a, fields: %i[a]
    end
  end

  it "adds a groundwork_flow macro to ActionDispatch::Routing::Mapper" do
    expect(ActionDispatch::Routing::Mapper.instance_methods).to include(:groundwork_flow)
  end

  it "can draw per-page member routes from a flow" do
    routes = ActionDispatch::Routing::RouteSet.new

    expect {
      routes.draw do
        resources :widgets do
          groundwork_flow RoutesFlow
        end
      end
    }.not_to raise_error

    helpers = routes.url_helpers
    expect(helpers).to respond_to(:edit_a_widget_path)
    expect(helpers).to respond_to(:update_a_widget_path)
  end
end

