class Book < ApplicationRecord
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  
  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}
  
  scope :latest, -> {order(created_at: :desc)}
  scope :old, -> {order(created_at: :asc)}
  scope :star_count, -> {order(star: :desc)}
  
  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end
  
  def save_tags(savebook_tags)
    # 現在のユーザーの持っているskillを引っ張ってきている
    current_tags = self.tags.pluck(:name) unless self.tags.nil?
    # 今bookが持っているタグと今回保存されたものの差をすでにあるタグとする。古いタグは消す。
    old_tags = current_tags - savebook_tags
    # 今回保存されたものと現在の差を新しいタグとする。新しいタグは保存
    new_tags = savebook_tags - current_tags
		
    # Destroy old taggings:
    old_tags.each do |old_name|
      self.tags.delete Tag.find_by(name:old_name)
    end
		
    # Create new taggings:
    new_tags.each do |new_name|
      book_tag = Tag.find_or_create_by(name:new_name)
      # 配列に保存
      self.tags << book_tag
    end
  end
  
  def self.search_for(content, method)
    if method == 'perfect'
      Book.where(title: content)
    elsif method == 'forward'
      Book.where('title LIKE ?', content+'%')
    elsif method == 'backward'
      Book.where('title LIKE ?', '%'+content)
    else
      Book.where('title LIKE ?', '%'+content+'%')
    end
  end
  
end
