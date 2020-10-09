# frozen_string_literal: true

require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    def expect_include(expense, included)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to(include included)
    end
    def expect_parsed( match, expected)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to(match expected)
    end

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end
        
        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          expect_parsed(:include, 'expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end
      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end
        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect_parsed(:include,  'error' => 'Expense incomplete' )
        end
        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
    describe 'GET /expenses/:date' do 
      context 'when expenses exist on the given date' do 
        let(:date) { '2017-06-12'}

        before do
          allow(ledger).to receive(:expenses_on)
          .with(date)
          .and_return([
            { 'id' => 1, 'date' => '2017-06-12', 'amount' => '10.0' },
            { 'id' => 2, 'date' => '2017-06-12', 'amount' => '11.0' }
          ])
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2017-06-12'
          expect_parsed(:match_array, 
          [{ 'id' => 1, 'date' => '2017-06-12', 'amount' => '10.0' },
          { 'id' => 2, 'date' => '2017-06-12', 'amount' => '11.0' }])
        end
        it 'responds with a 200 (OK)' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end 
      context 'when there are no expenses on the given date' do 
        let(:date) { '2017-06-12'}

        before do
          allow(ledger).to receive(:expenses_on)
          .with(date)
          .and_return([])
        end
        it 'returns an empty array as JSON' do
          get '/expenses/2017-06-12'
          expect_parsed(:eq, [])
        end
        it 'responds with a 200 (OK)' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end 
    end
  end
end
