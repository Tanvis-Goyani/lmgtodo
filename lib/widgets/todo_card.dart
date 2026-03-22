import 'package:flutter/material.dart';
import 'package:lmgtodo/models/todo_model.dart';
import 'package:lmgtodo/constants/app_colors.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    required this.onStart,
    required this.onPause,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (todo.status) {
      TodoStatus.todo => AppColors.statusTodo,
      TodoStatus.inProgress => AppColors.statusInProgress,
      TodoStatus.done => AppColors.statusDone,
      TodoStatus.incomplete => Colors.orange,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              _StatusChip(
                                status: todo.status,
                                statusColor: statusColor,
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: onEdit,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: onDelete,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.destructive.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.destructive,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            todo.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                todo.isRunning
                                    ? Icons.timer_rounded
                                    : Icons.timer_outlined,
                                size: 16,
                                color: todo.isRunning
                                    ? AppColors.statusInProgress
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(todo.remainingSeconds),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: todo.isRunning
                                      ? AppColors.statusInProgress
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (todo.status != TodoStatus.done &&
                                  todo.status != TodoStatus.incomplete &&
                                  todo.remainingSeconds > 0)
                                todo.isRunning
                                    ? _TimerButton(
                                        icon: Icons.pause_rounded,
                                        label: 'Pause',
                                        color: AppColors.statusInProgress,
                                        onTap: onPause,
                                      )
                                    : _TimerButton(
                                        icon: Icons.play_arrow_rounded,
                                        label: todo.status == TodoStatus.todo
                                            ? 'Start'
                                            : 'Resume',
                                        color: AppColors.statusDone,
                                        onTap: onStart,
                                      ),
                              const SizedBox(width: 8),

                              _TimerButton(
                                icon: Icons.check_rounded,
                                label: 'Done',
                                color: Colors.green,
                                onTap: onComplete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final TodoStatus status;
  final Color statusColor;

  const _StatusChip({required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TodoStatus.todo => 'TODO',
      TodoStatus.inProgress => 'In Progress',
      TodoStatus.done => 'Done',
      TodoStatus.incomplete => 'Timeout',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: statusColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
