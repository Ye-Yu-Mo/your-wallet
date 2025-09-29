import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/api_service.dart';
import '../router_singleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const AccountsPage(),
    const TransactionsPage(),
    const AssetsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                globalRouter?.go('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('个人资料'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('设置'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('退出登录'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '总览',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: '账户',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '交易',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '资产',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 1) {
            // 账户页面 - 添加账户
            _navigateToAddAccount();
          } else {
            // 其他页面 - 快速添加交易
            _showAddTransactionDialog();
          }
        },
        child: Icon(_currentIndex == 1 ? Icons.account_balance_wallet : Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddAccount() async {
    final result = await context.push('/add-account');
    if (result == true) {
      // 刷新账户页面数据
      setState(() {});
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加交易'),
        content: const Text('快速添加交易功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '总资产',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥ 0.00',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+0.00 (0.00%)',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '快速操作',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to add income
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle, color: Colors.green, size: 32),
                          SizedBox(height: 8),
                          Text('收入'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to add expense
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.remove_circle, color: Colors.red, size: 32),
                          SizedBox(height: 8),
                          Text('支出'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to transfer
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.blue, size: 32),
                          SizedBox(height: 8),
                          Text('转账'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '最近交易',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无交易记录',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];
  bool _isLoading = true;
  late AccountService _accountService;
  int? _userId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _accountService = AccountService(auth.apiService);
    _userId = auth.userId;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final uid = _userId;
      if (uid == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }
      final accounts = await _accountService.getAccounts(uid);
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载账户失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _accounts.isEmpty
            ? _buildEmptyState()
            : _buildAccountsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无账户',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加您的第一个账户',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAccount(),
            icon: const Icon(Icons.add),
            label: const Text('添加账户'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return _buildAccountCard(account);
        },
      ),
    );
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAccountTypeColor(account.accountType),
          child: Icon(
            _getAccountTypeIcon(account.accountType),
            color: Colors.white,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account.accountType),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${account.currency} ${account.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: account.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditAccountDialog(account);
                    break;
                  case 'delete':
                    _confirmDeleteAccount(account);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showAccountDetails(account),
        onLongPress: () => _showAccountOptions(account),
      ),
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bank': return Colors.blue;
      case 'credit': return Colors.orange;
      case 'cash': return Colors.green;
      case 'investment': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getAccountTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank': return Icons.account_balance;
      case 'credit': return Icons.credit_card;
      case 'cash': return Icons.payments;
      case 'investment': return Icons.trending_up;
      default: return Icons.account_balance_wallet;
    }
  }

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('账户类型', account.accountType),
            _buildDetailRow('余额', '${account.currency} ${account.balance.toStringAsFixed(2)}'),
            _buildDetailRow('货币', account.currency),
            _buildDetailRow('创建时间', _formatDate(account.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditAccountDialog(account);
            },
            child: const Text('编辑'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteAccount(account);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showAccountOptions(Account account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑账户'),
            onTap: () {
              Navigator.of(context).pop();
              _showEditAccountDialog(account);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除账户', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
              _confirmDeleteAccount(account);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddAccount() async {
    final result = await context.push('/add-account');
    if (result == true) {
      // 如果成功添加了账户，刷新列表
      _loadAccounts();
    }
  }

  void _showEditAccountDialog(Account account) {
    _showAccountForm(account: account);
  }

  void _showAccountForm({Account? account}) {
    final nameController = TextEditingController(text: account?.name ?? '');
    final balanceController = TextEditingController(text: account?.balance.toString() ?? '0');
    String selectedType = account?.accountType ?? 'bank';
    String selectedCurrency = account?.currency ?? 'CNY';

    final accountTypes = ['bank', 'credit', 'cash', 'investment'];
    final currencies = ['CNY', 'USD', 'EUR', 'HKD'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(account == null ? '添加账户' : '编辑账户'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '账户名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '账户类型',
                    border: OutlineInputBorder(),
                  ),
                  items: accountTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getAccountTypeDisplayName(type)),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: '余额',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: '货币',
                    border: OutlineInputBorder(),
                  ),
                  items: currencies.map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedCurrency = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => _saveAccount(
                account?.id,
                nameController.text,
                selectedType,
                double.tryParse(balanceController.text) ?? 0.0,
                selectedCurrency,
              ),
              child: Text(account == null ? '添加' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccountTypeDisplayName(String type) {
    switch (type) {
      case 'bank': return '银行账户';
      case 'credit': return '信用卡';
      case 'cash': return '现金';
      case 'investment': return '投资账户';
      default: return type;
    }
  }

  Future<void> _saveAccount(int? id, String name, String type, double balance, String currency) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账户名称'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.of(context).pop();

    try {
      if (id == null) {
        // Create new account
        final request = CreateAccountRequest(
          name: name.trim(),
          accountType: type,
          balance: balance,
          currency: currency,
        );
        await _accountService.createAccount(request, 1); // TODO: Use actual user ID
      } else {
        // Update existing account
        final request = UpdateAccountRequest(
          name: name.trim(),
          accountType: type,
          balance: balance,
          currency: currency,
        );
        await _accountService.updateAccount(id, request);
      }

      await _loadAccounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(id == null ? '账户添加成功' : '账户更新成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: const Text('确认删除账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要删除以下账户吗？'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getAccountTypeColor(account.accountType),
                    child: Icon(
                      _getAccountTypeIcon(account.accountType),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${account.currency} ${account.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '此操作无法撤销，账户的所有交易记录也将被删除',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(account),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(Account account) async {
    Navigator.of(context).pop();

    try {
      await _accountService.deleteAccount(account.id);
      await _loadAccounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账户删除成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      String message = '删除失败';
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        message = data['error'] as String;
      } else if (e.message != null) {
        message = e.message!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('交易页面开发中...'),
    );
  }
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('资产页面开发中...'),
    );
  }
}
