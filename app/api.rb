# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative 'ledger'
require 'byebug'

module ExpenseTracker
  # An API to keep track of expenses
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end
    get '/expenses/:date' do
      results = @ledger.expenses_on(params['date'])
      unless results == []
        status 200
        JSON.generate(results)
      else
        status 200
        JSON.generate([])
      end
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)
      if result.success?
        status 200
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end
  end
end
