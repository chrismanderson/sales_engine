require 'sales_engine/model'

class SalesEngine
  class Invoice
    ATTRIBUTES = %w(id created_at updated_at
          merchant_id customer_id merchant status)
    def self.finder_attributes
      ATTRIBUTES
    end

    include Model

    attr_accessor :merchant_id, :customer_id, :customer,
      :id, :merchant, :status, :created_at, :updated_at

    def initialize(attributes)
      super
      @customer_id = attributes[:customer_id].to_i
      @merchant_id = attributes[:merchant_id].to_i
      @status = attributes[:status]
    end

    def customer=(input)
      @customer_id = input.id
      @customer = input
    end

    def merchant=(input)
      @merchant_id = input.id
      @merchant = input
    end

    def transactions
      SalesEngine::Transaction.find_all_by_invoice_id(@id)
    end

    def invoice_items
      SalesEngine::InvoiceItem.find_all_by_invoice_id(@id)
    end

    def customer
      @customer || SalesEngine::Customer.find_by_id(@customer_id)
    end

    def merchant
      @merchant || SalesEngine::Merchant.find_by_id(@merchant_id)
    end

    def items
      invoice_items.collect do |invoice_item|
        invoice_item.item
      end
    end

    def total
      @total || invoice_items.inject(0) {|sum, element| sum + element.total}
    end

    def total=(input)
      @total = input
    end

    def self.add_to_db(input)
      if self.find_by_id(input.id) == nil
        SalesEngine::Database.instance.invoices << input
      end
    end

    def self.create(attr)
      invoice = self.new ( { :customer_id => attr[:customer].id,
        :merchant_id => attr[:merchant].id, :status => attr[:status] } )
      # add invoice items
      last_id = SalesEngine::Database.instance.invoices.last.id
      invoice.id =last_id + 1
      self.add_to_db(invoice)
      invoice
    end
  end
end
