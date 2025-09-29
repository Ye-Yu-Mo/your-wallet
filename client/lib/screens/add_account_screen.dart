import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../models/account.dart';
import '../services/account_service.dart';
// Uses ApiService from AuthProvider
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  String _selectedType = 'bank';
  String _selectedCurrency = 'CNY';
  bool _isLoading = false;

  // AccountService will be created on demand using AuthProvider's ApiService

  final List<AccountType> _accountTypes = [
    AccountType('bank', '银行账户', Icons.account_balance, Colors.blue),
    AccountType('credit', '信用卡', Icons.credit_card, Colors.orange),
    AccountType('cash', '现金', Icons.payments, Colors.green),
    AccountType('investment', '投资账户', Icons.trending_up, Colors.purple),
    AccountType('saving', '储蓄账户', Icons.savings, Colors.teal),
    AccountType('loan', '贷款账户', Icons.account_balance_wallet, Colors.red),
  ];

  final List<String> _currencies = ['CNY', 'USD', 'EUR', 'HKD', 'JPY', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加账户'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAccount,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 账户名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '账户名称',
                  hintText: '例如：招商银行储蓄卡',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入账户名称';
                  }
                  if (value.trim().length < 2) {
                    return '账户名称至少需要2个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 账户类型选择
              Text(
                '账户类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAccountTypeSelector(),
              const SizedBox(height: 24),

              // 初始余额
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: '初始余额',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入初始余额';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: '货币',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies.map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedCurrency = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 添加说明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '温馨提示',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 账户名称建议包含银行名称或账户用途\n'
                      '• 初始余额可以是当前实际余额\n'
                      '• 创建后可以随时修改账户信息',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _accountTypes.length,
      itemBuilder: (context, index) {
        final type = _accountTypes[index];
        final isSelected = _selectedType == type.value;

        return InkWell(
          onTap: () => setState(() => _selectedType = type.value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? type.color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? type.color.withOpacity(0.1) : Colors.white,
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type.icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? type.color : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = CreateAccountRequest(
        name: _nameController.text.trim(),
        accountType: _selectedType,
        balance: double.parse(_balanceController.text),
        currency: _selectedCurrency,
      );

      final auth = context.read<AuthProvider>();
      final uid = auth.userId;
      if (uid == null) {
        throw Exception('未登录或会话已过期');
      }
      final service = AccountService(auth.apiService);
      await service.createAccount(request, uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账户添加成功'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // 返回 true 表示成功添加
      }
    } on DioException catch (e) {
      String message = '添加失败';
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
            content: Text('添加失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class AccountType {
  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  AccountType(this.value, this.displayName, this.icon, this.color);
}
