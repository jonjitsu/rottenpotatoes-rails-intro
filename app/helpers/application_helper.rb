module ApplicationHelper

  def sortable_header(column, title, options={})
    css_classes = []
    sorted_column = sort_column
    direction = sort_direction
    if sorted_column && column==sorted_column
      css_classes << "hilite"
      css_classes << direction
    end

    direction = direction.nil?||direction=='desc' ? 'asc' : 'desc'

    params = filters 
    params[:sort] = column
    params[:direction] = direction
    content_tag(:th, {:class => css_classes.join(' ')}) do
      link_to title, params, options
    end
  end

  # Hash -> String
  # Given a hash produce a unique string hash encoding for it
  def hash_hash(h)
    require 'digest/md5'
    Digest::MD5.hexdigest(Marshal::dump(h.sort))
  end
end
