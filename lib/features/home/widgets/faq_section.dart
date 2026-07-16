import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// FAQ Section — mirrors FaqSection / FAQ.jsx from lallafy.com
class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  String _activeTab = 'Ordering';
  int? _expandedIndex;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_FaqTab> _tabs = [
    _FaqTab(name: 'Ordering', icon: Icons.shopping_bag_outlined),
    _FaqTab(name: 'Shipping', icon: Icons.local_shipping_outlined),
    _FaqTab(name: 'Payments', icon: Icons.credit_card_outlined),
    _FaqTab(name: 'Returns', icon: Icons.replay_rounded),
    _FaqTab(name: 'Support', icon: Icons.phone_outlined),
  ];

  static const Map<String, List<_FaqData>> _faqData = {
    'Ordering': [
      _FaqData(
        q: 'How do I place an order?',
        a: 'Browse products, add items to cart and proceed to checkout to complete payment.',
      ),
      _FaqData(
        q: 'Do you offer bulk order discounts?',
        a: 'Yes, bulk discounts are available. Contact our support team for details.',
      ),
      _FaqData(
        q: 'Can I order without creating an account?',
        a: 'Yes, guest checkout is available.',
      ),
      _FaqData(
        q: 'How can I track my order?',
        a: 'You will receive a tracking link via SMS/email after dispatch.',
      ),
      _FaqData(
        q: 'Can I modify my order after placing it?',
        a: 'Orders can be modified before dispatch.',
      ),
    ],
    'Shipping': [
      _FaqData(
        q: 'How long does delivery take?',
        a: 'Delivery usually takes 3–7 business days.',
      ),
      _FaqData(
        q: 'Do you offer express shipping?',
        a: 'Express shipping is available in selected cities.',
      ),
      _FaqData(
        q: 'Do you ship internationally?',
        a: 'Currently we ship only within India.',
      ),
      _FaqData(
        q: 'How are shipping charges calculated?',
        a: 'Shipping charges depend on location and order value.',
      ),
      _FaqData(
        q: 'Is free shipping available?',
        a: 'Free shipping available on selected promotions.',
      ),
    ],
    'Payments': [
      _FaqData(
        q: 'What payment methods are accepted?',
        a: 'We accept UPI, debit/credit cards and net banking.',
      ),
      _FaqData(
        q: 'Is Cash on Delivery available?',
        a: 'COD available on selected pincodes.',
      ),
      _FaqData(
        q: 'Is online payment secure?',
        a: 'Yes, all transactions are encrypted.',
      ),
      _FaqData(
        q: 'Will I get an invoice?',
        a: 'Invoice will be emailed after purchase.',
      ),
    ],
    'Returns': [
      _FaqData(
        q: 'What is your return policy?',
        a: 'Returns accepted within 7 days of delivery.',
      ),
      _FaqData(
        q: 'How do I initiate a return?',
        a: 'Contact support with order ID.',
      ),
      _FaqData(
        q: 'When will I receive my refund?',
        a: 'Refunds processed within 5–7 days.',
      ),
      _FaqData(
        q: 'What if I receive damaged product?',
        a: 'Report within 24 hours with images.',
      ),
    ],
    'Support': [
      _FaqData(
        q: 'How can I contact support?',
        a: 'Reach us via email or WhatsApp.',
      ),
      _FaqData(
        q: 'What are support working hours?',
        a: '9 AM – 6 PM.',
      ),
      _FaqData(
        q: 'How quickly will I get response?',
        a: 'Within 24 working hours.',
      ),
      _FaqData(
        q: 'Where can I check offers?',
        a: 'Offers listed on homepage.',
      ),
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqData> get _currentFaqs {
    final list = _faqData[_activeTab] ?? [];
    if (_searchQuery.trim().isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      return item.q.toLowerCase().contains(q) || item.a.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _currentFaqs;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // ── Support Badge & Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'SUPPORT CENTER',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF448C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C23),
                      letterSpacing: -0.5,
                    ),
                    children: const [
                      TextSpan(text: 'How Can We '),
                      TextSpan(
                        text: 'Help You?',
                        style: TextStyle(color: Color(0xFFFF448C)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find everything you need to know about ordering, shipping, payments, and returns.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // ── Search Input ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _expandedIndex = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search your question...',
                      hintStyle: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF448C)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _expandedIndex = null;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Category Tabs (Horizontal Chips) ──
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isActive = _activeTab == tab.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab.name;
                      _expandedIndex = null;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1A1C23) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? const Color(0xFF1A1C23) : Colors.grey.shade200,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1A1C23).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          size: 16,
                          color: isActive ? const Color(0xFFFF448C) : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tab.name,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : const Color(0xFF1A1C23),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── Accordion FAQ Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: faqs.isNotEmpty
                ? Column(
                    children: List.generate(faqs.length, (index) {
                      final item = faqs[index];
                      final isExpanded = _expandedIndex == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isExpanded ? const Color(0xFFFF448C) : Colors.grey.shade200,
                            width: isExpanded ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isExpanded
                                  ? const Color(0xFFFF448C).withOpacity(0.06)
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            key: Key('faq_${_activeTab}_$index'),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _expandedIndex = expanded ? index : null;
                              });
                            },
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(
                              item.q,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isExpanded
                                    ? const Color(0xFFFF448C)
                                    : const Color(0xFF1A1C23),
                              ),
                            ),
                            trailing: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? const Color(0xFFFF448C)
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: isExpanded ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 14,
                                ),
                                child: Text(
                                  item.a,
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                : Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No matching questions found',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqTab {
  final String name;
  final IconData icon;

  const _FaqTab({required this.name, required this.icon});
}

class _FaqData {
  final String q;
  final String a;

  const _FaqData({required this.q, required this.a});
}
