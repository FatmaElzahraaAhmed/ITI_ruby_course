class Article < ApplicationRecord
    include Visible
  
    has_many :comments, dependent: :destroy
    belongs_to :user
    has_one_attached :image
  
    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }
  
    after_commit :check_reports_count
  
    def report!
      increment!(:reports_count)
      save!
    end
  
    def reported?
      reports_count >= 3
    end
  
    private
  
    def check_reports_count
      if reported? && !archived?
        update!(status: 'archived')
      end
    end
  end
  