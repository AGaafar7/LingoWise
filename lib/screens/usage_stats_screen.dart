import 'package:flutter/material.dart';
import 'package:lingowise/services/subscription_service.dart';
import 'package:lingowise/screens/subscription_renewal_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({Key? key}) : super(key: key);

  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  int _remainingUnits = 0;
  bool _isLoading = true;
  List<FlSpot> _usageHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
    _subscriptionService.addSubscriptionListener(_onSubscriptionChanged);
  }

  @override
  void dispose() {
    _subscriptionService.removeSubscriptionListener(_onSubscriptionChanged);
    super.dispose();
  }

  void _onSubscriptionChanged(bool hasSubscription) {
    if (!hasSubscription) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionRenewalScreen(),
        ),
      );
    }
  }

  Future<void> _loadUsageStats() async {
    setState(() => _isLoading = true);
    
    try {
      final units = await _subscriptionService.getUnits();
      final lastUsage = await _subscriptionService.getLastUsage();
      
      // Simulate usage history data (replace with real data in production)
      _usageHistory = List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        return FlSpot(
          date.millisecondsSinceEpoch.toDouble(),
          (units + (index * 10)).toDouble(),
        );
      });

      setState(() {
        _remainingUnits = units;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading usage stats: $e')),
      );
    }
  }

  Widget _buildUsageChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _usageHistory,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageHistory() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(Duration(days: index));
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text('${date.day}/${date.month}/${date.year}'),
          subtitle: Text('Used ${(index + 1) * 5} units'),
          trailing: Text('${_remainingUnits + (index + 1) * 5} remaining'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsageStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Remaining Units',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_remainingUnits',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (_remainingUnits <= 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Low on units! Consider renewing your subscription.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Usage History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsageChart(),
            const SizedBox(height: 24),
            _buildUsageHistory(),
            if (_remainingUnits <= 10)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionRenewalScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Renew Subscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 