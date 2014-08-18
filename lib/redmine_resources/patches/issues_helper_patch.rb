module RedmineResources
  module Patches
    module IssuesHelperPatch       
      def self.included(base)
        # base.send(:include, InstanceMethods)
        base.class_eval do
          #begin instance methods
          alias_method :original_show_detail, :show_detail

          def show_detail(detail, no_html=false, options={})
            output = original_show_detail(detail, no_html, options)
            if output.nil? && detail.property == IssueResource::JOURNAL_DETAIL_PROPERTY
              label = l(:label_journal_resource_estimation)
              value = "#{detail.value}"
              unless no_html
                label = content_tag('strong', label)
              end
              output = "#{label} #{value}".html_safe
            end
            output
          end


         # end of instance methods
        end
      end
    end # module patch
  end
end
