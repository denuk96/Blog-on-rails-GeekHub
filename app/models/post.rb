class Post < ApplicationRecord
  belongs_to :author
  has_many :comments, dependent: :destroy
  ###???
  accepts_nested_attributes_for :comments

  has_one_attached :picture, dependent: :destroy

  validates :author_id, presence: true
  validates :title, :content, :picture, presence: true,
                                        length: { minimum: 5 }

  # impressionist
  is_impressionable
end
