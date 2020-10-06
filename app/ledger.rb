# frozen_string_literal: true

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  # A ledger to keep track of expenses
  class Ledger
    def record(expense); end
  end
end
