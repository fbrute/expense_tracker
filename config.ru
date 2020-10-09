# frozen_string_literal: true

require_relative 'app/api'
require 'pry-remote'
run ExpenseTracker::API.new
