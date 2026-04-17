// lib/features/host/screens/host_stay_availability_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';

class HostStayAvailabilityScreen extends StatefulWidget {
  final String stayId;

  const HostStayAvailabilityScreen({
    super.key,
    required this.stayId,
  });

  @override
  State<HostStayAvailabilityScreen> createState() => _HostStayAvailabilityScreenState();
}

class _HostStayAvailabilityScreenState extends State<HostStayAvailabilityScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isSaving = false;

  // Toggle state for 9 to 5 daily availability
  bool _isAlwaysAvailable9to5 = false;

  // Selected date range
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // NEW: Keep track of dates marked as available to show on the UI
  final Set<DateTime> _availableDates = {};

  @override
  void initState() {
    super.initState();
    // Optional: If you have a method to fetch existing availability from the backend,
    // call it here and populate _availableDates so previously saved dates show up.
    _loadExistingAvailability();
  }

  Future<void> _loadExistingAvailability() async {
    // Example placeholder: If you fetch data from the backend, loop through the dates
    // and add them to _availableDates, then call setState(() {}).
  }

  // NEW: Helper method to add a range of dates to our local state
  void _markDatesAsAvailableLocal(DateTime start, DateTime end) {
    DateTime current = DateTime(start.year, start.month, start.day);
    final DateTime endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      // Remove any existing exact matches to avoid duplicates
      _availableDates.removeWhere((d) => isSameDay(d, current));
      _availableDates.add(current);
      current = current.add(const Duration(days: 1));
    }
  }

  Future<void> _saveAvailability() async {
    if (!_isAlwaysAvailable9to5 && (_rangeStart == null || _rangeEnd == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range or enable Always Available')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<HostProvider>();

    final startDate = _isAlwaysAvailable9to5
        ? DateTime.now()
        : _rangeStart!;
    final endDate = _isAlwaysAvailable9to5
        ? DateTime.now().add(const Duration(days: 60))
        : _rangeEnd!;

    final success = await provider.setStayAvailability(widget.stayId, {
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      if (_isAlwaysAvailable9to5) 'start_time': '09:00',
      if (_isAlwaysAvailable9to5) 'end_time': '17:00',
      if (_isAlwaysAvailable9to5) 'is_always_available': true,
      'total_room': 1,
      'is_available': true,
    });

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated! ✓'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        setState(() {
          // NEW: Immediately update the local UI with the newly available dates
          _markDatesAsAvailableLocal(startDate, endDate);

          if (!_isAlwaysAvailable9to5) {
            _rangeStart = null;
            _rangeEnd = null;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Availability',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAvailability,
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
            )
                : const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Always Available 9 to 5 Toggle Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAlwaysAvailable9to5 ? Colors.blue.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isAlwaysAvailable9to5 ? Colors.blue.withOpacity(0.3) : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time_filled, color: Colors.blue, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Always Available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAlwaysAvailable9to5,
                        onChanged: (val) => setState(() => _isAlwaysAvailable9to5 = val),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Turn this on to mark your stay as available every day for the next 60 days. You can turn this off anytime to resume manual scheduling.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Hide Calendar if the Always Available toggle is ON
            if (!_isAlwaysAvailable9to5) ...[
              Container(
                color: Colors.white,
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,

                  // NEW: Visually highlight the dates marked as available
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final isAvailable = _availableDates.any((d) => isSameDay(d, day));
                      if (isAvailable) {
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), // Emerald green dot
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),

                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Helper Legend (Optional: lets user know what the green dot means)
              if (!_isAlwaysAvailable9to5)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                      SizedBox(width: 8),
                      Text('Available for booking', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),

              if (_rangeStart != null && _rangeEnd != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Selected Range',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_rangeStart!.toLocal().toString().split(' ')[0]} - ${_rangeEnd!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}