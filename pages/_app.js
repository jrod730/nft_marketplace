import '../styles/globals.css';
import { ThemeProvider } from 'next-themes';
import Script from 'next/script';
import { Navbar, Footer } from '../components/index';
import { NftProvider } from '../context/NftContext';

const MyApp = ({ Component, pageProps }) => (
  <NftProvider>
    <ThemeProvider attribute="class">
      <div className="dark:bg-nft-dark bg-white min-h-screen">
        <Navbar />
        <div className="pt-65">
          <Component {...pageProps} />
        </div>
        <Footer />
      </div>
      <Script src="https://kit.fontawesome.com/b5083fa894.js" crossOrigin="anonymous" />
    </ThemeProvider>
  </NftProvider>
);

export default MyApp;
