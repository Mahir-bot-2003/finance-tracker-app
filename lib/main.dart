import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:csv/csv.dart';
// Note: For file saving and sharing on a real device, you'd typically use packages like path_provider and share_plus

// Main function to run the application
void main() {
  runApp(const BudgetApp());
}

// Data model for a single expense transaction
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// The root widget of the application
class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigoAccent,
        ),
      ),
      home: const BudgetHomePage(),
    );
  }
}

// The main home page widget, which is stateful
class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  double _monthlyIncome = 5000.0; // Default monthly income
  final List<Expense> _expenses = [
    // Example data for demonstration purposes
    Expense(id: 'e1', title: 'Groceries', amount: 340.50, date: DateTime.now().subtract(const Duration(days: 2)), category: 'Food'),
    Expense(id: 'e2', title: 'Gasoline', amount: 80.00, date: DateTime.now().subtract(const Duration(days: 3)), category: 'Transport'),
    Expense(id: 'e3', title: 'New Jacket', amount: 150.00, date: DateTime.now().subtract(const Duration(days: 5)), category: 'Shopping'),
    Expense(id: 'e4', title: 'Movie Tickets', amount: 45.00, date: DateTime.now().subtract(const Duration(days: 1)), category: 'Entertainment'),
  ];

  // --- UI Methods ---

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment);
    });
  }

  void _startAddNewExpense(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: NewExpenseSheet(addExpenseHandler: _addNewExpense),
      ),
    );
  }

  // --- Local Data Logic ---

  void _addNewExpense(String title, double amount, String category) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(), // Expense is always added to the current date
      category: category,
    );
    setState(() {
      _expenses.add(newExpense);
    });
  }

  void _setIncome(double income) {
    setState(() {
      _monthlyIncome = income;
    });
  }

  void _showSetIncomeDialog() {
    final TextEditingController incomeController = TextEditingController(text: _monthlyIncome > 0 ? _monthlyIncome.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Set Monthly Income', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: incomeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Income', labelStyle: TextStyle(color: Colors.white70)),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              final double? enteredIncome = double.tryParse(incomeController.text);
              if (enteredIncome == null || enteredIncome <= 0) return;
              _setIncome(enteredIncome);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAiSuggestionsDialog(List<Expense> expenses) {
    List<String> suggestions = [];
    final totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final remainingBalance = _monthlyIncome - totalExpenses;

    Map<String, double> categorySpending = {};
    for (var expense in expenses) {
      categorySpending.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
    }

    if (_monthlyIncome <= 0) {
      suggestions.add("Set your monthly income to get personalized advice.");
    } else {
      final foodPercentage = (categorySpending['Food'] ?? 0.0) / _monthlyIncome * 100;
      final shoppingPercentage = (categorySpending['Shopping'] ?? 0.0) / _monthlyIncome * 100;
      final entertainmentPercentage = (categorySpending['Entertainment'] ?? 0.0) / _monthlyIncome * 100;
      final totalExpensePercentage = totalExpenses / _monthlyIncome * 100;

      if (totalExpensePercentage > 90) {
        suggestions.add("Your expenses are very high (${totalExpensePercentage.toStringAsFixed(1)}% of income). It's crucial to review non-essential spending immediately.");
      }
      if (foodPercentage > 25) {
        suggestions.add("Your food spending is ${foodPercentage.toStringAsFixed(1)}% of income. Consider planning meals or cooking at home more often to save money.");
      }
      if (shoppingPercentage > 20) {
        suggestions.add("Shopping accounts for ${shoppingPercentage.toStringAsFixed(1)}% of income. Try to differentiate between wants and needs before making a purchase.");
      }
      if (entertainmentPercentage > 15) {
        suggestions.add("Entertainment spending is at ${entertainmentPercentage.toStringAsFixed(1)}%. Look for free or low-cost activities like visiting a park or library.");
      }
      if (remainingBalance > _monthlyIncome * 0.2) {
        suggestions.add("Great job! You're saving over 20% of your income. Consider investing this surplus to grow your wealth.");
      }
    }
    if (suggestions.isEmpty) {
      suggestions.add("Your spending looks balanced this month. Keep up the great work!");
    }

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('AI Budget Assistant', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.map((s) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.cyanAccent),
            title: Text(s, style: const TextStyle(color: Colors.white70)),
          )).toList(),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
    ));
  }

  void _exportToCsv(List<Expense> expenses) {
    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Title', 'Amount', 'Date', 'Category']);
    for (var expense in expenses) {
      rows.add([expense.id, expense.title, expense.amount, DateFormat('yyyy-MM-dd').format(expense.date), expense.category]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    print(csv); // For debugging, prints CSV data to the console.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget data exported! (Check debug console for CSV output)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Filter expenses for the currently selected month
    final monthlyExpenses = _expenses.where((exp) {
      return exp.date.year == _selectedMonth.year && exp.date.month == _selectedMonth.month;
    }).toList();

    final totalExpenses = monthlyExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final remainingBalance = _monthlyIncome - totalExpenses;

    Map<String, double> categorySpending = {};
    for (var expense in monthlyExpenses) {
      categorySpending.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budget'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildMonthSelector(monthlyExpenses),
            _buildSummaryCard(_monthlyIncome, totalExpenses, remainingBalance),
            if (monthlyExpenses.isNotEmpty) _buildChartsCard(categorySpending),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('Transactions this Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildExpenseList(monthlyExpenses),
            const SizedBox(height: 80), // Space for FloatingActionButton
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewExpense(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Child Widgets ---

  Widget _buildMonthSelector(List<Expense> expenses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
          Column(
            children: [
              Text(DateFormat('MMMM yyyy').format(_selectedMonth), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.lightbulb_outline, color: Colors.yellow), onPressed: () => _showAiSuggestionsDialog(expenses), tooltip: 'AI Assistant'),
                  IconButton(icon: const Icon(Icons.download, color: Colors.cyanAccent), onPressed: () => _exportToCsv(expenses), tooltip: 'Export to CSV'),
                ],
              )
            ],
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expenses, double balance) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SUMMARY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.5)),
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: _showSetIncomeDialog, tooltip: 'Set Income'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Income', currencyFormat.format(income), Colors.green),
                _buildSummaryItem('Expenses', currencyFormat.format(expenses), Colors.red),
              ],
            ),
            const Divider(height: 40, color: Colors.white24),
            Column(
              children: [
                const Text('Balance', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(balance),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.cyanAccent : Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      children: <Widget>[
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildChartsCard(Map<String, double> categorySpending) {
    return Card(
        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('EXPENSE BREAKDOWN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              PieChart(
                dataMap: categorySpending,
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                centerText: "SPENDING",
                legendOptions: const LegendOptions(
                  showLegendsInRow: true,
                  legendPosition: LegendPosition.bottom,
                  showLegends: true,
                  legendTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                  decimalPlaces: 1,
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    return expenses.isEmpty
        ? const Center(child: Padding(
      padding: EdgeInsets.all(50.0),
      child: Text('No transactions this month!', style: TextStyle(color: Colors.white70)),
    ))
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: FittedBox(child: Text('\$${expense.amount.toStringAsFixed(0)}')),
              ),
            ),
            title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${expense.category} | ${DateFormat.yMMMd().format(expense.date)}'),
          ),
        );
      },
    );
  }
}

// Widget for the bottom sheet to add a new expense
class NewExpenseSheet extends StatefulWidget {
  final Function(String, double, String) addExpenseHandler;
  const NewExpenseSheet({super.key, required this.addExpenseHandler});

  @override
  State<NewExpenseSheet> createState() => _NewExpenseSheetState();
}

class _NewExpenseSheetState extends State<NewExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Other'];

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredTitle.isEmpty || enteredAmount == null || enteredAmount <= 0) return;
    widget.addExpenseHandler(enteredTitle, enteredAmount, _selectedCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        color: const Color(0xFF1E1E1E),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _submitData(),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                dropdownColor: const Color(0xFF2A2A2A),
                items: _categories.map((String category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (newValue) => setState(() { _selectedCategory = newValue!; }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}