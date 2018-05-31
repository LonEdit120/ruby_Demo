require 'googlecharts'
# global variable
# set symbol array for expense
$expenseType = [:eating, :shopping, :medical, :entertain, :others]

# define Outputfile module, which would be included in Record
# the module have two methods: pie_output and bar_output
module OutputFile
    # define output pie chart function
    # @param
    # expense: an array of hash pair
    def pie_output(expense)
        data = [expense[:eating], expense[:shopping], expense[:medical], expense[:entertain], expense[:others]]
        labels = ['eating','shopping','medical','entertain','others']
        # define pie attribute
        pie_chart = Gchart.new(
            :type => 'pie',
            :title => "Expense Pie Chart",
            :size => '400x200',
            :data => data,
            :labels => labels,
            :filename => "pie_chart.png"
        )
        pie_chart.file
        puts "pie generated !"
    end
    # define output bar chart function
    # @param
    # income: number
    # expense: an array of hash pair
    def bar_output(income, expense)
        # show three bars: income, expense, all parts of expense
        data = Array.new
        # deal with data
        # first deal with income
        data << [income, 0, 0]
        # then deal with expense
        cost = 0
        for key in $expenseType
            cost += expense[key]
        end
        data << [0, cost, 0]
        # last deal with all parts of expense
        0.upto($expenseType.length-1) do |i|
            data << [0, 0, expense[$expenseType.at(i)]]
        end
        # define bar attribute
        bar_chart = Gchart.new(
            :type => 'bar',
            :size => '1000x300',
            :encoding => 'extended',
            :orientation => 'horizontal',
            :title => "Income vs Expense",
            :data => data,
            :legend => ['income', 'expense', 'eating', 'shopping', 'medical', 'entertain', 'others'],
            :legend_position => 'bottom',
            :bg => 'FAFAFA',
            :bar_colors => ['E76F51', 'F4A261', 'E9C46A', '2A9D8F', '6FFFE9', '5BC0BE', '3A506B'],
            :bar_width_and_spacing => [50,20],
            :max_value => income + 5000,
            :axis_with_labels => ['y', 'x'],
            :axis_labels => [nil],
            :filename => "bar_chart.png"
        )
        bar_chart.file
        puts "bar generated !"
    end
    # define output line chart function
    # @param
    # list: an array of hash pair
    def line_output(list)
        deposit = 0
        data = Array.new
        for item in list
            deposit += item[:cost]
            data << deposit
        end
        line_chart = Gchart.new(
            :type => 'line',
            :title => 'deposit',
            :data => data,
            :axis_with_labels => 'y',
            :filename => 'line_chart.png'
        )
        line_chart.file
        puts "line generated !"
    end
end

class Record
    # include module: OutputFile
    include OutputFile
    # income with one number
    # expense with five number: eat, shop, medical, entertain, others
    # define constructor
    attr_reader :income, :expense, :list
    def initialize
        @income  = 0
        @expense = {eating: 0, shopping: 0, medical: 0, entertain: 0, others: 0}
        @list    = Array.new
    end
    # define save function
    # param:
    # income: the cost user save: number
    def save(income)
        @income += income
        time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
        @list << {cost: income, type: "income", time: time}
    end
    # define spend function
    # param:
    # type: the type spend money: eat, shop, medical, entertain, others
    # cost: the money user spend: number
    def spend(type, cost)
        @expense[type] += cost
        time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
        @list << {cost: -cost, type: type, time: time}
    end
end

# 1 save money
# 2 record expense
# 3 show expense pie chart
# 4 Output income vs expense
# 5 Output deposit line chart
# 6 list all records

# main function
# create record instance
$record = Record.new
loop do
    puts "Input your operation :\n1.Save money\n2.Record expense\n3.Output expense pie chart\n4.Output income vs expense bar chart\n5.Output deposit line chart\n6.List all records"
    print "Option : "
    op = Integer($stdin.gets)
    puts "=========================================================="
    case op
        when 1 # save money
            print "How much was your income ?\n$ "
            income = Integer($stdin.gets)
            $record.save(income)
        when 2 # spend money
            puts "Please input your type of expense :\n1.eating\n2.shopping\n3.medical\n4.entertain\n5.others"
            type = Integer($stdin.gets)
            if (1..5).include?(type)
                print "How much was the expense ?\n$ "
                cost = Integer($stdin.gets)
                $record.spend($expenseType.at(type-1), cost)
            else
                puts "wtf? Are you kidding me?"
            end
        when 3 # output pie chart, show costs of all types
            $record.pie_output($record.expense)
        when 4 # output bar chart, show income & expense and all types
            $record.bar_output($record.income, $record.expense)
        when 5
            $record.line_output($record.list)
        when 6
            0.upto($record.list.length-1) do |i|
                puts "type: #{$record.list.at(i)[:type]}, cost: #{$record.list.at(i)[:cost]}, time: #{$record.list.at(i)[:time]}"
            end
            cost = 0;
            for key in $expenseType do
                cost += $record.expense[key];
            end
            profit = $record.income - cost
            puts "Total deposit from the list : $ #{profit}\n\n"
        else
            puts "insert only number between 1~6"
    end
end
