module RedmineGroupByName
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.alias_method_chain :grouped_issue_list, :group_by_name
      end

      module InstanceMethods
        def grouped_issue_list_with_group_by_name(issues, query, issue_count_by_group, &block)
          # overwriting issue_count_by_group
          issue_count_by_group = issue_count_by_stringified_groups(issues, query) if query.group_by_column

          previous_group, first = false, true
          totals_by_group = query.totalable_columns.inject({}) do |h, column|
            h[column] = query.total_by_group_for(column)
            h
          end
          issue_list(issues) do |issue, level|
            group_name = group_count = nil
            if query.grouped?
              # changing group identity by string
              group = query.group_by_column.value(issue).to_s
              if first || group != previous_group
                if group.blank? && group != false
                  group_name = "(#{l(:label_blank_value)})"
                else
                  group_name = format_object(group)
                end
                group_name ||= ""
                group_count = issue_count_by_group[group]
                group_totals = totals_by_group.map {|column, t| total_tag(column, t[group] || 0)}.join(" ").html_safe
              end
            end
            yield issue, level, group_name, group_count, group_totals
            previous_group, first = group, false
          end
        end

        def issue_count_by_stringified_groups(issues, query)
          new_group_counts = Hash.new(0)
          issue_list(issues) do |issue|
            group_name = query.group_by_column.value(issue).to_s
            new_group_counts[group_name] += 1
          end
          new_group_counts
        end
      end
    end
  end
end

IssuesHelper.send :include, RedmineGroupByName::Patches::IssuesHelperPatch
