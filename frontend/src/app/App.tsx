import { QueryClientProvider } from '@tanstack/react-query';
import { AppRouter } from '@/app/router';
import { queryClient } from '@/core/lib/queryClient';

/**
 * @component App
 * @summary Root application component with providers
 * @domain core
 * @type root-component
 * @category application
 */
export const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AppRouter />
    </QueryClientProvider>
  );
};
