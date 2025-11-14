/**
 * @page HomePage
 * @summary Home page displaying welcome message
 * @domain core
 * @type page-component
 * @category public
 */
export const HomePage = () => {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Bem-vindo ao LoveCakes</h1>
        <p className="text-lg text-gray-600">Bolos artesanais feitos com amor</p>
      </div>
    </div>
  );
};

export default HomePage;
