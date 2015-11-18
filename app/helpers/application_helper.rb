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

    content_tag(:th, {:class => css_classes.join(' ')}) do
      link_to title, {:sort => column, :direction => direction }, options
    end
  end

end
