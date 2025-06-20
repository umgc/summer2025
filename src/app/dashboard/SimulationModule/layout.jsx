import TuckedHeader from "@/app/Header/TuckedHeader/TuckedHeader";

export default function CourseLayout({ children }) {
  return (
    <>
      {/* Tucked Header */}
      <TuckedHeader />
      {children}
    </>
  );
}
