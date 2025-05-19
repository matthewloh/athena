# Supabase Edge Functions with Riverpod

## Overview

This document provides a comprehensive guide on integrating Supabase Edge Functions with Riverpod for state management in Flutter applications. We'll explore how to create, deploy, and consume Supabase Edge Functions while leveraging Riverpod's powerful state management capabilities to handle asynchronous operations.

## Table of Contents

1. [Introduction](#introduction)
2. [Setting Up Supabase Edge Functions](#setting-up-supabase-edge-functions)
3. [Riverpod Integration](#riverpod-integration)
4. [Complete Implementation Example](#complete-implementation-example)
5. [Deployment Tutorial](#deployment-tutorial)
6. [Best Practices](#best-practices)

## Introduction

Supabase Edge Functions allow you to run server-side code in a secure, scalable environment without managing servers. When combined with Riverpod's state management, you can create robust Flutter applications with clean separation of concerns and efficient handling of asynchronous operations.

Key benefits of this integration:

- **Serverless Architecture**: Run backend code without maintaining infrastructure
- **Type-Safe State Management**: Riverpod provides type safety and dependency management
- **Clean Architecture**: Separation of UI, state management, and data access
- **Efficient Async Handling**: Built-in support for loading, error, and success states

## Setting Up Supabase Edge Functions

### 1. Basic Edge Function Structure

Here's a simple Supabase Edge Function that accepts a name parameter and returns a greeting:

```typescript
// supabase/functions/hello-name/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

console.info("server started");
Deno.serve(async (req) => {
  const { name } = await req.json();

  // Add artificial delay to simulate loading
  await new Promise((resolve) => setTimeout(resolve, 3000));

  const data = {
    message: `Hello ${name}! You are using the edge function!`,
  };

  return new Response(JSON.stringify(data), {
    headers: {
      "Content-Type": "application/json",
      Connection: "keep-alive",
    },
  });
});
```

This function:

- Accepts a JSON request with a "name" parameter
- Simulates processing with a 3-second delay
- Returns a greeting message

## Riverpod Integration

### 1. Creating Providers

Riverpod enables clean integration with Supabase Edge Functions through dedicated providers:

```dart
// Edge function call provider
@riverpod
Future<Map<String, dynamic>> helloEdgeFunction(Ref ref, String userName) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase.functions.invoke(
    'hello-name',
    body: {'name': userName},
  );

  return response.data as Map<String, dynamic>;
}

// Provider to track the input name
@riverpod
class EdgeFunctionName extends _$EdgeFunctionName {
  @override
  String build() {
    return 'Scholar';
  }

  void updateName(String name) {
    state = name;
  }
}
```

### 2. Handling Async States

Riverpod's powerful async value handling gives you elegant control over loading, error, and success states:

```dart
Consumer(
  builder: (context, ref, child) {
    final name = ref.watch(edgeFunctionNameProvider);
    final asyncResponse = ref.watch(helloEdgeFunctionProvider(name));

    return asyncResponse.when(
      data: (data) {
        // Success state
        return _buildSuccessState(data);
      },
      loading: () {
        // Loading state
        return _buildLoadingState();
      },
      error: (error, stackTrace) {
        // Error state
        return _buildErrorState(error);
      },
    );
  },
),
```

### 3. UI Implementation

Creating UI components for each state:

```dart
Widget _buildSuccessState(Map<String, dynamic> data) {
  return AnimatedOpacity(
    opacity: 1.0,
    duration: const Duration(milliseconds: 500),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.athenaBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.athenaBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data['message'] ?? 'No message received',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLoadingState() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 16),
        Text('Calling edge function...'),
      ],
    ),
  );
}

Widget _buildErrorState(Object error) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red[200]!),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Error: ${error.toString()}',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
```

## Complete Implementation Example

A complete demo UI showing the integration:

```dart
void _showEdgeFunctionDemo(BuildContext context, WidgetRef ref) {
  final currentName = ref.read(edgeFunctionNameProvider);
  final textController = TextEditingController(text: currentName);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.athenaBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.cloudy_snowing, color: AppColors.athenaBlue),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Supabase Edge Function',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final name = textController.text.trim();
                          if (name.isNotEmpty) {
                            ref.read(edgeFunctionNameProvider.notifier).updateName(name);
                            // Force rebuild by invalidating the provider
                            ref.invalidate(helloEdgeFunctionProvider(name));
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        ref.read(edgeFunctionNameProvider.notifier).updateName(value);
                        // Force rebuild by invalidating the provider
                        ref.invalidate(helloEdgeFunctionProvider(value));
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            final name = ref.watch(edgeFunctionNameProvider);
                            final asyncResponse = ref.watch(helloEdgeFunctionProvider(name));

                            return asyncResponse.when(
                              data: (data) => _buildSuccessState(data),
                              loading: () => _buildLoadingState(),
                              error: (error, stackTrace) => _buildErrorState(error),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Async State Management:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Riverpod provides typesafe async state handling\n'
                    '• .when() handles all states: data, loading, error\n'
                    '• Edge functions run in isolated environments\n'
                    '• StateProvider tracks user input across rebuilds',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
```

## Deployment Tutorial

### Local Development

1. **Create a New Edge Function**:

   ```bash
   supabase functions new hello-name
   ```

2. **Edit Function Code**:
   Create/modify the file at `supabase/functions/hello-name/index.ts`

3. **Test Locally**:

   ```bash
   supabase functions serve hello-name --no-verify-jwt
   ```

   This runs your function locally at <http://localhost:54321/functions/v1/hello-name>

4. **Test with cURL**:

   ```bash
   curl -X POST http://localhost:54321/functions/v1/hello-name \
     -H "Content-Type: application/json" \
     -d '{"name":"World"}'
   ```

### Deployment

1. **Log in to Supabase**:

   ```bash
   supabase login
   ```

2. **Link to Your Project**:

   ```bash
   supabase link --project-ref YOUR_PROJECT_ID
   ```

3. **Deploy Function**:

   ```bash
   supabase functions deploy hello-name
   ```

4. **Deploy with CORS Settings** (if needed):

   ```bash
   supabase functions deploy hello-name --no-verify-jwt --cors-allowlist="*"
   ```

5. **Set Environment Variables** (if needed):

   ```bash
   supabase secrets set MY_API_KEY=value
   ```

6. **Verify Deployment**:
   Check your Supabase dashboard at <https://supabase.com/dashboard/project/YOUR_PROJECT_ID/functions>

## Riverpod Architecture Educational Notes

### Key Concepts

1. **Providers**:

   - **Definition**: A provider is a typed reference to a specific piece of state
   - **Purpose**: Create, read, and modify state in a type-safe way
   - **Types**:
     - `Provider`: Immutable read-only value
     - `StateProvider`: Simple mutable state
     - `FutureProvider`: Asynchronous data
     - `StreamProvider`: Stream of asynchronous data
     - `StateNotifierProvider`: Complex state with encapsulated logic
     - `NotifierProvider`: Modern replacement for StateNotifierProvider (Riverpod 2.0+)

2. **Ref**:

   - **Usage**: Read other providers and listen to their changes
   - **Methods**:
     - `ref.watch()`: Subscribes to a provider, rebuilding when it changes
     - `ref.read()`: One-time read, no subscription
     - `ref.listen()`: React to provider changes without rebuilding

3. **AsyncValue**:

   - **Purpose**: Safely handle asynchronous states
   - **States**:
     - `AsyncData`: Successfully loaded data
     - `AsyncLoading`: Loading state
     - `AsyncError`: Error state
   - **Usage**: `asyncValue.when(data: (value) {}, loading: () {}, error: (error, stack) {})`

4. **Provider Families**:
   - **Purpose**: Create providers that accept parameters
   - **Usage**: `myProvider(parameter)` to instantiate with a specific parameter

### Architecture Benefits

1. **Dependency Injection**:

   - Providers can depend on other providers, forming a dependency graph
   - Dependencies are automatically updated when their dependencies change

2. **Testability**:

   - Easily override providers in tests for complete control over app state
   - Test UI in isolation with mocked providers

3. **Code Organization**:

   - Each provider represents a clear, single responsibility
   - Providers can be grouped by feature or domain area

4. **Efficient Rebuilds**:

   - Riverpod only rebuilds widgets that depend on changed state
   - Fine-grained reactive dependencies minimize unnecessary rebuilds

5. **Type Safety**:
   - All provider operations are fully typed
   - Compile-time errors for misuse of providers or state

## Best Practices

1. **Error Handling**:

   - Always implement error states in your UI
   - Consider retry mechanisms for failed requests
   - Use try-catch blocks in provider implementations

2. **Caching Strategies**:

   - Use `keepAlive: true` for providers that should persist data
   - Consider time-based cache invalidation for fresh data

3. **Performance Optimization**:

   - Use `select()` to listen to parts of state
   - Avoid rebuilding heavy UI components by extracting Consumer widgets

4. **Provider Organization**:

   - Keep providers close to where they're used (feature folders)
   - For global providers, consider a dedicated providers directory

5. **Edge Function Security**:
   - Use `--no-verify-jwt` only for public functions
   - For protected functions, implement proper authentication
   - Consider rate limiting for public-facing functions

## Conclusion

The combination of Supabase Edge Functions and Riverpod provides a powerful foundation for building scalable, maintainable Flutter applications. Edge Functions provide serverless backend capabilities, while Riverpod offers a clean, type-safe approach to state management.

This integration allows developers to:

- Build fully reactive applications with clean separation of concerns
- Handle complex asynchronous operations with elegant state management
- Deploy backend logic without managing infrastructure
- Create highly testable components with clear dependencies

By following the patterns and practices outlined in this document, you can leverage these technologies to build robust Flutter applications that scale well and maintain clean code architecture.
