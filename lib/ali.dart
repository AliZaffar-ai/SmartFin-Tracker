import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp
  runApp(SmartFin());
}

class SmartFin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFin App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StartPage(), // Start with StartPage
      routes: {
        '/home': (context) => HomePage(selectedIndex: 0),
        '/profile': (context) => ProfilePage(),
        '/add_money': (context) => AddMoneyPage(),
        '/withdraw_money': (context) => WithdrawMoneyPage(),
        '/sign_in': (context) => SignInPage(),
        '/sign_up': (context) => SignUpPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => UndefinedView(name: settings.name));
      },
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to SmartFin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '/Users/apple/NEW FOLDER/Ali/smartfin/images/WhatsApp Image 2023-12-13 at 3.07.09 PM.jpeg', // Replace with the path to your image asset
              width: 400, // Adjust the width as needed
              height: 400, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class MoneyTransaction {
  final double amount;
  final DateTime date;

  MoneyTransaction(this.amount, this.date);
}

class AddMoneyPage extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Add your money'),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  double addedAmount = double.parse(amountController.text);
                  Navigator.pop(context, addedAmount);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class WithdrawMoneyPage extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Withdraw your money'),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  double withdrawnAmount = double.parse(amountController.text);
                  Navigator.pop(context, withdrawnAmount);
                }
              },
              child: const Text('Withdraw'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.selectedIndex}) : super(key: key);

  final int selectedIndex;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MoneyTransaction> moneyTransactions = [];
  double totalMoney = 6400.0;

  @override
  Widget build(BuildContext context) {
    final tabViews = [
      buildMoneyView(context),
      SavingsPage(),
      ExpensePage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFin APP'),
      ),
      body: IndexedStack(
        index: widget.selectedIndex,
        children: tabViews,
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  Widget buildMoneyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Your Money', style: TextStyle(fontSize: 18)),
                      Text('\$$totalMoney',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var result = await Navigator.pushNamed(
                        context,
                        '/add_money',
                      );

                      if (result != null && result is double) {
                        setState(() {
                          totalMoney += result;
                          moneyTransactions.add(
                            MoneyTransaction(result, DateTime.now()),
                          );
                        });
                      }
                    },
                    child: const Text('Add Money'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var result = await Navigator.pushNamed(
                        context,
                        '/withdraw_money',
                      );

                      if (result != null && result is double) {
                        if (totalMoney >= result) {
                          setState(() {
                            totalMoney -= result;
                            moneyTransactions.add(
                              MoneyTransaction(-result, DateTime.now()),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Insufficient funds for withdrawal'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Withdraw Money'),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Text('Total money \$64,000',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle done tap
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      onTap: (int index) {
        if (widget.selectedIndex != index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(selectedIndex: index)),
          );
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.money_rounded),
          label: 'Money',
          backgroundColor: widget.selectedIndex == 0 ? Colors.lightBlue[900] : Colors.white,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.savings),
          label: 'Savings',
          backgroundColor: widget.selectedIndex == 1 ? Colors.lightBlue[900] : Colors.white,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: 'Expense',
          backgroundColor: widget.selectedIndex == 2 ? Colors.lightBlue[900] : Colors.white,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'Profile',
          backgroundColor: widget.selectedIndex == 3 ? Colors.lightBlue[900] : Colors.white,
        ),
      ],
      type: BottomNavigationBarType.shifting,
    );
  }
}

class UndefinedView extends StatelessWidget {
  final String? name;

  UndefinedView({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route not found'),
      ),
      body: Center(
        child: Text('Route: $name not defined'),
      ),
    );
  }
}



// New ExpensePage class
class ExpensePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data for the bar chart
    final data = [
      ExpenseData('Sat', 50),
      ExpenseData('Sun', 70),
      // ... Add other days data
    ];

    var series = [
      charts.Series(
        id: 'Expenses',
        domainFn: (ExpenseData expenses, _) => expenses.day,
        measureFn: (ExpenseData expenses, _) => expenses.amount,
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expense'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Handle calendar icon action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more icon action
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: chart,
          ),
          // Add the rest of the expense page content here
        ],
      ),
    
    );
  }
}

class ExpenseData {
  final String day;
  final double amount;

  ExpenseData(this.day, this.amount);
}



class ProfilePage extends StatelessWidget {
  final List<String> textList = [
    "Personal information",
    "Account link",
    "Change password",
    "Sign out"
  ];
  final List<IconData> iconList = [
    Icons.person,
    Icons.link_sharp,
    Icons.admin_panel_settings_sharp,
    Icons.logout
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(270),
        child: Container(
          height: 270,
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Color.fromRGBO(210, 234, 251, 1),
                    ),
                    radius: 35,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    "User name",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors. blueGrey, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.crop_free),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          "Free",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.sports_golf,
                      size: 30,
                    ),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: iconList.length,
              itemBuilder: (context, int) {
                return SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                iconList[int],
                                size: 30,
                              ),
                              onPressed: () async {
                                // Handle the button press based on the index
                                switch (int) {
                                  case 0:
                                    // Personal Information
                                    break;
                                  case 1:
                                    // Account Link
                                    break;
                                  case 2:
                                    // Change Password
                                    break;
                                  case 3:
                                    // Sign Out
                                    // Uncomment the following lines if you have access to authentication methods
                                    await _auth.signOut();
                                    Navigator.pushReplacementNamed(context, '/home');
                                    break;
                                }
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              textList[int],
                              style: TextStyle(fontSize: 25),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 0,
                        thickness: 0.8,
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}


class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add the image widget here
            Image.asset(
              '/Users/apple/NEW FOLDER/Ali/smartfin/images/WhatsApp Image 2023-12-13 at 3.07.09 PM.jpeg', // Replace with the path to your image asset
              width: 300, // Adjust the width as needed
              height: 300, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.popAndPushNamed(context, '/home');  // Redirect to home page
                } catch (e) {
                  print('Sign In Error: $e');
                  String errorMessage = 'An unexpected error occurred.';

                  if (e is FirebaseAuthException) {
                    switch (e.code) {
                      case 'invalid-email':
                        errorMessage = 'Invalid email address.';
                        break;
                      case 'user-not-found':
                        errorMessage = 'User not found. Please sign up.';
                        break;
                      case 'wrong-password':
                        errorMessage = 'Incorrect password.';
                        break;
                      case 'INVALID_LOGIN_CREDENTIALS':
                        errorMessage = 'Invalid login credentials.';
                        break;
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                    ),
                  );
                }
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}



class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add the image widget here
            Image.asset(
              '/Users/apple/NEW FOLDER/Ali/smartfin/images/WhatsApp Image 2023-12-13 at 3.07.09 PM.jpeg', // Replace with the path to your image asset
              width: 300, // Adjust the width as needed
              height: 300, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.pop(context); // Redirect to home page
                } catch (e) {
                  if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                    print('Email is already in use. Try signing in instead.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email is already in use. Try signing in instead.'),
                      ),
                    );
                  } else {
                    print('Sign Up Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign Up Error: $e'),
                      ),
                    );
                  }
                }
              },
              child: Text('Sign Up'),
            
            ),
          ],
        ),
      ),
    );
  }
}


class SavingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the size of the device screen
    MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('My savings'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // More button action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Budget is under control for at least 10 days\nYou saved \$1600.0 in January till now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildStatisticItem('Budget', '\$8,000.0'),
                  VerticalDivider(),
                  _buildStatisticItem('Expenses', '\$3,342.0'),
                  VerticalDivider(),
                  _buildStatisticItem('Savings', '\$1600.0'),
                ],
              ),
            ),
            Divider(),
            _buildProgressIndicator('This month', '\$1,600.0 of \$8,000.0', 0.2),
            _buildProgressIndicator('This week', '\$300.0 of \$1,500.0', 0.2),
            _buildProgressIndicator('Today', '\$0 of \$200.0', 0.0),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Change savings rules button action
              },
              child: Text(
                'Change savings rules',
                style: TextStyle(color: Colors.white), // Text color is white
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue[900], // Button background color is red
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(String title, String value, double percent) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title),
              Text(value),
            ],
          ),
          SizedBox(height: 5),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ],
      ),
    );
  }
}