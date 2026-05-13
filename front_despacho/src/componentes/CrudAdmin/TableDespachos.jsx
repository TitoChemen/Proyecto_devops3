import { useState, useEffect } from "react";
import { Modal } from "./Modal";
import { FormCierreDespacho } from "./FormCierreDespacho";
import { getDespachos } from "../../api/api"; // Importación de la API centralizada

export const TableDespachos = () => {
  const [despachos, setDespachos] = useState([]);
  const [loading, setLoading] = useState(true); // Estado para manejar la carga de datos
  const [openModal, setOpenModal] = useState(false);
  const [despachoSeleccionado, setDespachoSeleccionado] = useState(null);

  // Función para obtener los datos usando el servicio centralizado
  const fetchDespachos = async () => {
    try {
      setLoading(true);
      const response = await getDespachos();
      setDespachos(response.data);
    } catch (error) {
      console.error("Error al obtener los despachos:", error);
    } finally {
      setLoading(false);
    }
  };

  // Efecto para cargar datos al montar el componente
  useEffect(() => {
    fetchDespachos();
  }, []);

  const handleAbrirModal = (despacho) => {
    setDespachoSeleccionado(despacho);
    setOpenModal(true);
  };

  return (
    <>
      <section className="grid text-center grid-cols-12 mb-8">
        <div className="col-span-12 flex justify-center">
          <div className="col-span-10 p-2 bg-white border border-gray-200 rounded-lg shadow dark:bg-white h-full overflow-hidden">
            {loading ? (
              <div className="py-10 text-teal-600 font-bold">Cargando despachos...</div>
            ) : (
              <table className="table-fixed w-full">
                <thead>
                  <tr className="py-10 border-b">
                    <th className="pr-10">Orden de despacho</th>
                    <th className="pr-10">Orden de compra</th>
                    <th className="pr-10">Dirección de entrega</th>
                    <th className="pr-10">Fecha despacho</th>
                    <th className="pr-10">Patente Camión</th>
                    <th className="pr-10">Entregado</th>
                    <th className="pr-10">Intentos de entrega</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {despachos.map((despacho) => (
                    <tr key={despacho.idDespacho} className="hover:bg-gray-50 transition-colors">
                      <td className="pr-10 py-10 items-center">{despacho.idDespacho}</td>
                      <td className="pr-10 py-10 items-center">{despacho.idCompra}</td>
                      <td className="pr-10 py-10 items-center">{despacho.direccionCompra}</td>
                      <td className="pr-10 py-10 items-center">{despacho.fechaDespacho}</td>
                      <td className="pr-10 py-10 items-center">{despacho.patenteCamion}</td>
                      <td className="pr-10 py-10 items-center">
                        {despacho.entregado ? "Despacho entregado" : "Despacho pendiente"}
                      </td>
                      <td className="pr-10 py-10 items-center">{despacho.intento}</td>
                      <td>
                        <button
                          onClick={() => handleAbrirModal(despacho)}
                          className="py-1 bg-orange-200 px-8 rounded-xl shadow-md hover:bg-orange-300/70 transition-all duration-300"
                        >
                          Cerrar despacho
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </section>

      <Modal
        onClose={() => setOpenModal(false)}
        open={openModal}
      >
        {despachoSeleccionado && (
          <FormCierreDespacho
            despacho={despachoSeleccionado}
            onClose={() => {
              setOpenModal(false);
              fetchDespachos(); // Recarga la lista tras cerrar el despacho
            }}
          />
        )}
      </Modal>
    </>
  );
};