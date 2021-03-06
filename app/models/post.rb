# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  title      :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :bigint
#

class Post < ApplicationRecord
  belongs_to :author
  has_many :comments, dependent: :destroy
  has_one_attached :picture, dependent: :destroy
  accepts_nested_attributes_for :comments

  validates :author_id, presence: true
  validates :title, :content, :picture, presence: true,
                                        length: { minimum: 5 }
  validates :title, uniqueness: { scope: :author_id },
                    length: { minimum: 5, maximum: 20 }

  def self.search(search)
    where('title ILIKE ? OR content ILIKE ?', "%#{search}%", "%#{search}%")
  end

  # impressionist
  is_impressionable
end
