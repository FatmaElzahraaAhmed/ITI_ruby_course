require 'time'

module CustomLogger
  def log_info(message)
    record_log("info", message)
  end

  def log_warning(message)
    record_log("warning", message)
  end

  def log_error(message)
    record_log("error", message)
  end

  private

  def record_log(log_type, message)
    File.open("app.log", "a") do |file|
      file.puts "#{Time.now.to_s} - #{log_type.upcase} - #{message}"
    end
  end
end

class Account
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

class TransactionRecord
  attr_reader :account, :amount

  def initialize(account, amount)
    @account = account
    @amount = amount
  end
end

class BankingSystem
  def process_transactions(transactions, &callback)
    transaction_info = transactions.map { |trans| "#{trans.account.name} transaction with amount #{trans.amount}" }.join(", ")
    log_info("Processing Transactions: #{transaction_info}...")

    transactions.each do |trans|
      begin
        if trans.account.nil? || !bank_accounts.include?(trans.account)
          raise "Account does not exist"
        elsif trans.account.balance + trans.amount < 0
          raise "Insufficient balance"
        end

        log_info("#{trans.account.name} transaction with amount #{trans.amount} processed successfully")
        trans.account.balance += trans.amount

        if trans.account.balance.zero?
          log_warning("#{trans.account.name} has a zero balance")
        end

        callback.call("success", trans)
      rescue => e
        log_error("#{trans.account.name} transaction with amount #{trans.amount} failed: #{e.message}")
        callback.call("failure", trans)
      end
    end
  end
end

class CustomBank < BankingSystem
  include CustomLogger

  def initialize(accounts)
    @bank_accounts = accounts
  end

  def bank_accounts
    @bank_accounts
  end
end

accounts = [
  Account.new("Fatma", 200),
  Account.new("Sally", 500),
  Account.new("Salma", 100)
]

outside_accounts = [
  Account.new("Ahmed", 400)
]

transactions = [
  TransactionRecord.new(accounts[0], -20),
  TransactionRecord.new(accounts[0], -30),
  TransactionRecord.new(accounts[0], -50),
  TransactionRecord.new(accounts[0], -100),
  TransactionRecord.new(accounts[0], -100),
  TransactionRecord.new(outside_accounts[0], -100)
]

custom_bank = CustomBank.new(accounts)
custom_bank.process_transactions(transactions) do |status, transaction|
  reason = if status == 'failure'
             transaction.account.nil? || !custom_bank.bank_accounts.include?(transaction.account) ? "#{transaction.account.name} does not exist in the bank!" : "Insufficient balance"
           else
             nil
           end
  puts "Endpoint call: #{status.upcase} - #{transaction.account.name} transaction with amount #{transaction.amount} #{reason ? " - Reason: #{reason}" : ''}"
end
